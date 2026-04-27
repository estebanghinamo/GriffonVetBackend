<?php

namespace App\Services;

use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class SpService
{
    private const ERR_EMPTY = '{"success":0,"mensaje":"Sin respuesta del SP"}';
    private const ERR_NULL  = '{"success":0,"mensaje":"Respuesta vacía"}';

    /**
     * Ejecuta un SP de MySQL que retorna un result set con una sola columna JSON.
     * CALL sp_nombre(@param = ?) → MySQL: CALL sp_nombre(?)
     */
    public function ejecutar(string $sp, array $params = []): string
    {
        try {
            $placeholders = empty($params)
                ? ''
                : implode(', ', array_fill(0, count($params), '?'));

            $sql    = "CALL {$sp}({$placeholders})";
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
     * Login: en MySQL no hay OUTPUT params como en SQL Server.
     * El SP retorna una fila con los datos directamente en el result set.
     *
     * El SP en MySQL debería hacer un SELECT al final:
     *   SELECT 1 AS login_valido, email, rol, id_usuario FROM usuarios WHERE ...
     */
    public function ejecutarLogin(string $json): array
    {
        try {
            $result = DB::select("CALL sp_login_usuario_json(?)", [$json]);

            if (empty($result)) return ['login_valido' => 0];

            $row = (array) $result[0];

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
}