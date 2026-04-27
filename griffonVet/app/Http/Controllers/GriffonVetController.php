<?php

namespace App\Http\Controllers;

use App\Repositories\GriffonVetRepository;
use App\Services\JsonUtils;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Illuminate\Http\JsonResponse;

class GriffonVetController extends Controller
{
    public function __construct(
        private GriffonVetRepository $repo,
        private JsonUtils $jsonUtils        // ← inyectás el servicio
    ) {}

    // -------------------------------------------------------------------------
    // Helper
    // -------------------------------------------------------------------------

    private function buildResponse(string $json): Response
    {
        $decoded = json_decode($json, true);
        $status  = ($decoded['success'] ?? 1) == 0 ? 400 : 200;

        return response($json, $status)
            ->header('Content-Type', 'application/json');
    }

    // -------------------------------------------------------------------------
    // Usuarios
    // -------------------------------------------------------------------------

    public function registrarUsuario(Request $request): Response
    {
        return $this->buildResponse(
            $this->repo->registrarUsuario($request->getContent())
        );
    }

    public function activarUsuario(Request $request): Response
    {
        return $this->buildResponse(
            $this->repo->activarUsuario($request->query('token'))
        );
    }

    public function login(Request $request): JsonResponse
    {
        $result = $this->repo->login($request->getContent());

        if (($result['success'] ?? 0) == 0) {
            return response()->json($result, 401);
        }

        return response()->json($result);
    }

    // -------------------------------------------------------------------------
    // Clientes y mascotas
    // -------------------------------------------------------------------------

    public function insertarClienteMascotaAdmin(Request $request): Response
    {
        return $this->buildResponse(
            $this->repo->insertarClienteMascotaAdmin($request->getContent())
        );
    }

    public function getClientes(): Response
    {
        return $this->buildResponse($this->repo->getClientes());
    }

    public function obtenerClientesConMascotas(Request $request): Response
    {
        return $this->buildResponse(
            $this->repo->obtenerClientesConMascotas($request->getContent())
        );
    }

    public function obtenerMascotasPorUsuario(): Response
    {
        // Equivalente a jsonUtils.jsonSoloConIdUsuario()
        return $this->buildResponse(
            $this->repo->obtenerMascotasPorUsuario(
                $this->jsonUtils->jsonSoloConIdUsuario()
            )
        );
    }

    public function obtenerRecordatoriosMascotas(Request $request): Response
    {
        $body = $request->getContent();

        // Equivalente a la lógica del Spring:
        // si viene vacío → jsonSoloConIdUsuario, si viene JSON → resolverIdUsuario
        $payload = (empty(trim($body)))
            ? $this->jsonUtils->jsonSoloConIdUsuario()
            : $this->jsonUtils->resolverIdUsuario($body);

        return $this->buildResponse(
            $this->repo->obtenerRecordatoriosMascotas($payload)
        );
    }

    public function getMascota(Request $request): Response
    {
        return $this->buildResponse(
            $this->repo->getMascota($request->getContent())
        );
    }

    public function insertarMascota(Request $request): Response
    {
        // Equivalente a jsonUtils.resolverIdUsuario(json)
        return $this->buildResponse(
            $this->repo->insertarMascota(
                $this->jsonUtils->resolverIdUsuario($request->getContent())
            )
        );
    }

    public function editarInfoGeneralMascota(Request $request): Response
    {
        return $this->buildResponse(
            $this->repo->editarInfoGeneralMascota(
                $this->jsonUtils->resolverIdUsuario($request->getContent())
            )
        );
    }

    // -------------------------------------------------------------------------
    // Consultas clínicas
    // -------------------------------------------------------------------------

    public function insertarConsultaClinica(Request $request): Response
    {
        return $this->buildResponse(
            $this->repo->insertarConsultaClinica(
                $request->input('consulta'),
                $request->file('archivos')
            )
        );
    }

    public function actualizarConsultaClinica(Request $request): Response
    {
        return $this->buildResponse(
            $this->repo->actualizarConsultaClinica(
                $request->input('consulta'),
                $request->file('archivos')
            )
        );
    }

    public function eliminarConsulta(Request $request): Response
    {
        return $this->buildResponse(
            $this->repo->eliminarConsulta($request->getContent())
        );
    }

    // -------------------------------------------------------------------------
    // Categorías
    // -------------------------------------------------------------------------

    public function obtenerCategorias(): Response
    {
        return $this->buildResponse($this->repo->obtenerCategorias());
    }

    public function insertarCategoria(Request $request): Response
    {
        return $this->buildResponse(
            $this->repo->insertarCategoria($request->getContent())
        );
    }

    // -------------------------------------------------------------------------
    // Productos
    // -------------------------------------------------------------------------

    public function obtenerProductos(): Response
    {
        return $this->buildResponse($this->repo->obtenerProductos());
    }

    public function insertarProducto(Request $request): Response
    {
        return $this->buildResponse(
            $this->repo->insertarProducto(
                $request->file('imagen'),
                $request->input('producto')
            )
        );
    }

    public function actualizarProducto(Request $request): Response
    {
        return $this->buildResponse(
            $this->repo->actualizarProducto(
                $request->file('imagen'),
                $request->input('producto')
            )
        );
    }

    public function eliminarProducto(Request $request): Response
    {
        return $this->buildResponse(
            $this->repo->eliminarProducto($request->getContent())
        );
    }

    // -------------------------------------------------------------------------
    // Medicamentos
    // -------------------------------------------------------------------------

    public function obtenerMedicamentos(): Response
    {
        return $this->buildResponse($this->repo->obtenerMedicamentos());
    }

    public function insertarMedicamento(Request $request): Response
    {
        return $this->buildResponse(
            $this->repo->insertarMedicamento($request->getContent())
        );
    }

    // -------------------------------------------------------------------------
    // Vacunas
    // -------------------------------------------------------------------------

    public function obtenerVacunas(): Response
    {
        return $this->buildResponse($this->repo->obtenerVacunas());
    }

    public function insertarVacuna(Request $request): Response
    {
        return $this->buildResponse(
            $this->repo->insertarVacuna($request->getContent())
        );
    }

    public function insertarVacunacion(Request $request): Response
    {
        return $this->buildResponse(
            $this->repo->insertarVacunacion($request->getContent())
        );
    }

    // -------------------------------------------------------------------------
    // Desparasitación
    // -------------------------------------------------------------------------

    public function obtenerDesparasitaciones(): Response
    {
        return $this->buildResponse($this->repo->obtenerDesparasitaciones());
    }

    public function insertarDesparasitacion(Request $request): Response
    {
        return $this->buildResponse(
            $this->repo->insertarDesparasitacion($request->getContent())
        );
    }

    public function insertarDesparasitacionCatalogo(Request $request): Response
    {
        return $this->buildResponse(
            $this->repo->insertarDesparasitacionCatalogo($request->getContent())
        );
    }

    // -------------------------------------------------------------------------
    // Peso
    // -------------------------------------------------------------------------

    public function insertarPeso(Request $request): Response
    {
        return $this->buildResponse(
            $this->repo->insertarPeso($request->getContent())
        );
    }

    // -------------------------------------------------------------------------
    // Enfermedades
    // -------------------------------------------------------------------------

    public function obtenerEnfermedades(): Response
    {
        return $this->buildResponse($this->repo->obtenerEnfermedades());
    }

    public function insertarEnfermedad(Request $request): Response
    {
        return $this->buildResponse(
            $this->repo->insertarEnfermedad($request->getContent())
        );
    }

    public function insertarEnfermedadCatalogo(Request $request): Response
    {
        return $this->buildResponse(
            $this->repo->insertarEnfermedadCatalogo($request->getContent())
        );
    }

    // -------------------------------------------------------------------------
    // Alergias
    // -------------------------------------------------------------------------

    public function obtenerAlergias(): Response
    {
        return $this->buildResponse($this->repo->obtenerAlergias());
    }

    public function insertarAlergia(Request $request): Response
    {
        return $this->buildResponse(
            $this->repo->insertarAlergia($request->getContent())
        );
    }

    public function insertarAlergiaCatalogo(Request $request): Response
    {
        return $this->buildResponse(
            $this->repo->insertarAlergiaCatalogo($request->getContent())
        );
    }

    // -------------------------------------------------------------------------
    // Servicios
    // -------------------------------------------------------------------------

    public function obtenerServicios(): Response
    {
        return $this->buildResponse($this->repo->obtenerServicios());
    }

    public function insertarServicio(Request $request): Response
    {
        return $this->buildResponse(
            $this->repo->insertarServicio($request->getContent())
        );
    }

    public function actualizarServicio(Request $request): Response
    {
        return $this->buildResponse(
            $this->repo->actualizarServicio($request->getContent())
        );
    }

    public function eliminarServicio(Request $request): Response
    {
        return $this->buildResponse(
            $this->repo->eliminarServicio($request->getContent())
        );
    }

    public function obtenerServicioPorMascota(Request $request): Response
    {
        return $this->buildResponse(
            $this->repo->obtenerServicioPorMascota($request->getContent())
        );
    }

    // -------------------------------------------------------------------------
    // Home
    // -------------------------------------------------------------------------

    public function obtenerInfoHome(): Response
    {
        return $this->buildResponse($this->repo->obtenerInfoHome());
    }

    public function insertarInfoHome(Request $request): Response
    {
        return $this->buildResponse(
            $this->repo->insertarInfoHome(
                $request->file('imagen'),
                $request->input('data')
            )
        );
    }

    public function actualizarInfoHome(Request $request): Response
    {
        return $this->buildResponse(
            $this->repo->actualizarInfoHome(
                $request->file('imagen'),
                $request->input('data')
            )
        );
    }

    public function eliminarInfoHome(Request $request): Response
    {
        return $this->buildResponse(
            $this->repo->eliminarInfoHome($request->getContent())
        );
    }

    // -------------------------------------------------------------------------
    // Noticias y especies
    // -------------------------------------------------------------------------

    public function obtenerNoticias(): Response
    {
        return $this->buildResponse($this->repo->obtenerNoticias());
    }

    public function obtenerEspecies(): Response
    {
        return $this->buildResponse($this->repo->obtenerEspecies());
    }

    // -------------------------------------------------------------------------
    // Dashboard
    // -------------------------------------------------------------------------

    public function obtenerDashboardAdmin(): Response
    {
        return $this->buildResponse($this->repo->obtenerDashboardAdmin());
    }
}