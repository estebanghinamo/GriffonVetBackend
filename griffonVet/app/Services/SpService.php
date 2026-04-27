<?php

namespace App\Services;

use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class SpService
{
    private const ERR_EMPTY = '{"success":0,"mensaje":"Sin respuesta del SP"}';
    private const ERR_NULL  = '{"success":0,"mensaje":"Respuesta vacía"}';

    /**
     * Ejecuta un SP que retorna un result set con una sola columna JSON.
     * Cubre el 95% de los métodos del repositorio.
     */
    public function ejecutar(string $sp, array $params = []): string
    {
        try {
            $sql    = $this->buildExec($sp, $params);
            $result = DB::select($sql, array_values($params));

            if (empty($result)) return self::ERR_EMPTY;

            $value = array_values((array) $result[0])[0] ?? null;
            return $value !== null ? (string) $value : self::ERR_NULL;

        } catch (\Exception $e) {
            Log::error("SP [{$sp}] error: " . $e->getMessage());
            return '{"success":0,"mensaje":"Error interno: ' . addslashes($e->getMessage()) . '"}';
        }
    }

    /**
     * Ejecuta el SP de login que tiene parámetros OUTPUT.
     * Usa T-SQL para declarar variables locales, ejecutar el SP y seleccionar los outputs.
     */
    public function ejecutarLogin(string $json): array
    {
        try {
            $sql = "DECLARE @lv INT, @eo NVARCHAR(255), @r NVARCHAR(50), @iu INT;
                    EXEC dbo.sp_login_usuario_json
                        @json            = ?,
                        @login_valido    = @lv OUTPUT,
                        @email_out       = @eo OUTPUT,
                        @rol             = @r  OUTPUT,
                        @id_usuario      = @iu OUTPUT;
                    SELECT @lv AS login_valido, @eo AS email_out, @r AS rol, @iu AS id_usuario;";

            $rows = DB::select($sql, [$json]);

            if (empty($rows)) return ['login_valido' => 0];

            $row = (array) $rows[0];
            return [
                'login_valido' => (int) ($row['login_valido'] ?? 0),
                'email_out'    => $row['email_out']  ?? null,
                'rol'          => $row['rol']         ?? null,
                'id_usuario'   => isset($row['id_usuario']) ? (int) $row['id_usuario'] : null,
            ];

        } catch (\Exception $e) {
            Log::error('SP [sp_login_usuario_json] error: ' . $e->getMessage());
            return ['login_valido' => 0, 'mensaje' => $e->getMessage()];
        }
    }

    // -------------------------------------------------------------------------
    // Helpers
    // -------------------------------------------------------------------------

    private function buildExec(string $sp, array $params): string
    {
        if (empty($params)) {
            return "EXEC dbo.{$sp}";
        }

        $parts = [];
        foreach (array_keys($params) as $key) {
            $parts[] = "@{$key} = ?";
        }

        return "EXEC dbo.{$sp} " . implode(', ', $parts);
    }
}
