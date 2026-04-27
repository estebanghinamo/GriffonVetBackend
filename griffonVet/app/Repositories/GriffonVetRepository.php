<?php

namespace App\Repositories;

use App\Services\CloudinaryService;
use App\Services\SpService;
use Firebase\JWT\JWT;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Mail;
use Ramsey\Uuid\Uuid;

class GriffonVetRepository
{
    public function __construct(
        private SpService       $sp,
        private CloudinaryService $cloudinary
    ) {}

    // -------------------------------------------------------------------------
    // Usuarios
    // -------------------------------------------------------------------------

    public function registrarUsuario(string $json): string
    {
        try {
            $data = json_decode($json, true);
            $rol  = $data['rol'] ?? 'CLIENTE';

            if (strtoupper($rol) === 'CLIENTE') {
                $token          = \Illuminate\Support\Str::uuid()->toString();
                $data['token']  = $token;
                $nuevoJson      = json_encode($data);

                $response = $this->sp->ejecutar('sp_registrar_usuario', ['json' => $nuevoJson]);

                if (str_contains($response, '"success":1')) {
                    $this->enviarMailConfirmacion($data['email'], $token);
                }

                return $response;
            }

            return $this->sp->ejecutar('sp_registrar_usuario', ['json' => $json]);

        } catch (\Exception $e) {
            return '{"success":0,"mensaje":"Error: ' . addslashes($e->getMessage()) . '"}';
        }
    }

    public function login(string $json): array
    {
        try {
            $out = $this->sp->ejecutarLogin($json);

            if (!($out['login_valido'] ?? 0)) {
                return ['success' => 0, 'mensaje' => 'Email o contraseña incorrectos'];
            }

            return [
                'success' => 1,
                'token'   => $this->generarToken(
                    $out['email_out'],
                    $out['id_usuario'],
                    $out['rol']
                ),
            ];

        } catch (\Exception $e) {
            Log::error($e->getMessage());
            return ['success' => 0, 'mensaje' => 'Error interno: ' . $e->getMessage()];
        }
    }

    public function activarUsuario(string $token): string
    {
        return $this->sp->ejecutar('sp_activar_usuario', ['token' => $token]);
    }

    // -------------------------------------------------------------------------
    // Clientes y mascotas
    // -------------------------------------------------------------------------

    public function insertarClienteMascotaAdmin(string $json): string
    {
        return $this->sp->ejecutar('sp_insert_cliente_mascota_json', ['json' => $json]);
    }

    public function getClientes(): string
    {
        return $this->sp->ejecutar('sp_get_clientes_con_mascotas_json');
    }

    public function obtenerClientesConMascotas(string $json): string
    {
        return $this->sp->ejecutar('sp_get_clientes_con_mascotas_json_filtrado', ['json' => $json]);
    }

    public function obtenerMascotasPorUsuario(string $json): string
    {
        return $this->sp->ejecutar('sp_get_mascotas_por_usuario_json', ['json' => $json]);
    }

    public function obtenerRecordatoriosMascotas(string $json): string
    {
        return $this->sp->ejecutar('sp_get_recordatorios_mascotas_usuario_json', ['json' => $json]);
    }

    public function getMascota(string $json): string
    {
        return $this->sp->ejecutar('sp_get_informacioncompleta_mascota', ['json' => $json]);
    }

    public function insertarMascota(string $json): string
    {
        return $this->sp->ejecutar('sp_insert_mascota_json', ['json' => $json]);
    }

    public function editarInfoGeneralMascota(string $json): string
    {
        return $this->sp->ejecutar('sp_editar_infogeneral_mascota', ['json' => $json]);
    }

    // -------------------------------------------------------------------------
    // Consultas clínicas
    // -------------------------------------------------------------------------

    public function insertarConsultaClinica(string $json, ?array $archivos): string
    {
        $consulta = $this->procesarEstudios($json, $archivos);
        return $this->sp->ejecutar('sp_insert_consulta_clinica_json', ['json' => json_encode($consulta)]);
    }

    public function actualizarConsultaClinica(string $json, ?array $archivos): string
    {
        $consulta = $this->procesarEstudios($json, $archivos);
        return $this->sp->ejecutar('sp_update_consulta_clinica_json', ['json' => json_encode($consulta)]);
    }

    public function eliminarConsulta(string $json): string
    {
        return $this->sp->ejecutar('sp_delete_consulta_clinica_json', ['json' => $json]);
    }

    // -------------------------------------------------------------------------
    // Categorías
    // -------------------------------------------------------------------------

    public function obtenerCategorias(): string
    {
        return $this->sp->ejecutar('sp_get_categorias');
    }

    public function insertarCategoria(string $json): string
    {
        return $this->sp->ejecutar('sp_insert_categoria_json', ['json' => $json]);
    }

    // -------------------------------------------------------------------------
    // Productos
    // -------------------------------------------------------------------------

    public function obtenerProductos(): string
    {
        return $this->sp->ejecutar('sp_get_productos_json');
    }

    public function insertarProducto(?UploadedFile $imagen, string $productoJson): string
    {
        return $this->ejecutarSpConImagen('sp_insert_producto_json', $imagen, $productoJson);
    }

    public function actualizarProducto(?UploadedFile $imagen, string $productoJson): string
    {
        return $this->ejecutarSpConImagen('sp_update_producto_json', $imagen, $productoJson);
    }

    public function eliminarProducto(string $json): string
    {
        return $this->sp->ejecutar('sp_delete_producto_json', ['json' => $json]);
    }

    // -------------------------------------------------------------------------
    // Medicamentos
    // -------------------------------------------------------------------------

    public function obtenerMedicamentos(): string
    {
        return $this->sp->ejecutar('sp_get_medicamentos');
    }

    public function insertarMedicamento(string $json): string
    {
        return $this->sp->ejecutar('sp_insert_medicamento', ['json' => $json]);
    }

    // -------------------------------------------------------------------------
    // Vacunas y vacunación
    // -------------------------------------------------------------------------

    public function obtenerVacunas(): string
    {
        return $this->sp->ejecutar('sp_get_vacunas');
    }

    public function insertarVacuna(string $json): string
    {
        return $this->sp->ejecutar('sp_insert_vacuna_json', ['json' => $json]);
    }

    public function insertarVacunacion(string $json): string
    {
        return $this->sp->ejecutar('sp_insert_vacunacion_json', ['json' => $json]);
    }

    // -------------------------------------------------------------------------
    // Desparasitación
    // -------------------------------------------------------------------------

    public function obtenerDesparasitaciones(): string
    {
        return $this->sp->ejecutar('sp_get_desparasitaciones');
    }

    public function insertarDesparasitacion(string $json): string
    {
        return $this->sp->ejecutar('sp_insert_desparasitacion_mascota_json', ['json' => $json]);
    }

    public function insertarDesparasitacionCatalogo(string $json): string
    {
        return $this->sp->ejecutar('sp_insert_desparasitacion_catalogo_json', ['json' => $json]);
    }

    // -------------------------------------------------------------------------
    // Peso
    // -------------------------------------------------------------------------

    public function insertarPeso(string $json): string
    {
        return $this->sp->ejecutar('sp_insert_peso_json', ['json' => $json]);
    }

    // -------------------------------------------------------------------------
    // Enfermedades
    // -------------------------------------------------------------------------

    public function obtenerEnfermedades(): string
    {
        return $this->sp->ejecutar('sp_get_enfermedades');
    }

    public function insertarEnfermedad(string $json): string
    {
        return $this->sp->ejecutar('sp_insert_enfermedad_json', ['json' => $json]);
    }

    public function insertarEnfermedadCatalogo(string $json): string
    {
        return $this->sp->ejecutar('sp_insert_enfermedad_catalogo_json', ['json' => $json]);
    }

    // -------------------------------------------------------------------------
    // Alergias
    // -------------------------------------------------------------------------

    public function obtenerAlergias(): string
    {
        return $this->sp->ejecutar('sp_get_alergias');
    }

    public function insertarAlergia(string $json): string
    {
        return $this->sp->ejecutar('sp_insert_alergia_json', ['json' => $json]);
    }

    public function insertarAlergiaCatalogo(string $json): string
    {
        return $this->sp->ejecutar('sp_insert_alergia_catalogo_json', ['json' => $json]);
    }

    // -------------------------------------------------------------------------
    // Servicios
    // -------------------------------------------------------------------------

    public function obtenerServicios(): string
    {
        return $this->sp->ejecutar('sp_get_servicios_json');
    }

    public function insertarServicio(string $json): string
    {
        return $this->sp->ejecutar('sp_insert_servicio_json', ['json' => $json]);
    }

    public function actualizarServicio(string $json): string
    {
        return $this->sp->ejecutar('sp_update_servicio_json', ['json' => $json]);
    }

    public function eliminarServicio(string $json): string
    {
        return $this->sp->ejecutar('sp_delete_servicio_json', ['json' => $json]);
    }

    public function obtenerServicioPorMascota(string $json): string
    {
        return $this->sp->ejecutar('sp_get_servicio_por_mascota', ['json' => $json]);
    }

    // -------------------------------------------------------------------------
    // Home
    // -------------------------------------------------------------------------

    public function obtenerInfoHome(): string
    {
        return $this->sp->ejecutar('sp_get_home_completo_json');
    }

    public function insertarInfoHome(?UploadedFile $imagen, string $datajson): string
    {
        return $this->ejecutarSpConImagen('sp_insert_informacion_home_json', $imagen, $datajson);
    }

    public function actualizarInfoHome(?UploadedFile $imagen, string $datajson): string
    {
        return $this->ejecutarSpConImagen('sp_update_informacion_home_json', $imagen, $datajson);
    }

    public function eliminarInfoHome(string $json): string
    {
        return $this->sp->ejecutar('sp_delete_informacion_home_json', ['json' => $json]);
    }

    // -------------------------------------------------------------------------
    // Noticias y especies
    // -------------------------------------------------------------------------

    public function obtenerNoticias(): string
    {
        return $this->sp->ejecutar('sp_get_noticias_json');
    }

    public function obtenerEspecies(): string
    {
        return $this->sp->ejecutar('sp_get_especies');
    }

    // -------------------------------------------------------------------------
    // Dashboard admin
    // -------------------------------------------------------------------------

    public function obtenerDashboardAdmin(): string
    {
        return $this->sp->ejecutar('sp_get_dashboard_admin_json', ['json' => '{}']);
    }

    // -------------------------------------------------------------------------
    // Helpers privados
    // -------------------------------------------------------------------------

    private function generarToken(string $correo, int $idUsuario, string $rol): string
    {
        $ahora      = time();
        $expiracion = $ahora + 7200; // 2 horas

        $payload = [
            'sub'        => $correo,
            'id_usuario' => $idUsuario,
            'rol'        => $rol,
            'iat'        => $ahora,
            'exp'        => $expiracion,
        ];

        return JWT::encode($payload, config('app.jwt_secret'), 'HS256');
    }

    private function procesarEstudios(string $json, ?array $archivos): array
    {
        $consulta = json_decode($json, true);
        $estudios = $consulta['estudios'] ?? null;

        if ($estudios === null) return $consulta;

        $fileIndex = 0;
        foreach ($estudios as &$estudio) {
            if ($archivos !== null && $fileIndex < count($archivos)) {
                $file = $archivos[$fileIndex];
                if ($file instanceof UploadedFile && !$file->getError()) {
                    try {
                        $estudio['resultado'] = $this->cloudinary->subirArchivo($file);
                    } catch (\Exception) {
                        $estudio['resultado'] = '';
                    }
                    $fileIndex++;
                } else {
                    $estudio['resultado'] = '';
                }
            } else {
                $estudio['resultado'] = '';
            }
        }
        unset($estudio);

        $consulta['estudios'] = $estudios;
        return $consulta;
    }

    private function ejecutarSpConImagen(string $sp, ?UploadedFile $imagen, string $datajson): string
    {
        try {
            $data = json_decode($datajson, true);
            if ($imagen !== null && !$imagen->getError()) {
                $data['imagen_url'] = $this->cloudinary->subirArchivo($imagen);
            }
            return $this->sp->ejecutar($sp, ['json' => json_encode($data)]);
        } catch (\Exception $e) {
            return '{"success":0,"mensaje":"Error interno: ' . addslashes($e->getMessage()) . '"}';
        }
    }

    private function enviarMailConfirmacion(string $email, string $token): void
    {
        try {
            $link = config('app.frontend_url') . '/activar?token=' . $token;

            Mail::raw(
                "Hacé click para activar tu cuenta:\n" . $link,
                function ($msg) use ($email) {
                    $msg->to($email)->subject('Activar cuenta GriffonVet');
                }
            );
        } catch (\Exception $e) {
            Log::error('Error enviando mail: ' . $e->getMessage());
        }
    }
}
