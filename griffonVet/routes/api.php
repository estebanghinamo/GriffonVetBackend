<?php

use App\Http\Controllers\GriffonVetController;
use App\Http\Middleware\JwtMiddleware;
use Illuminate\Support\Facades\Route;

// ─── Públicas ────────────────────────────────────────────────────────────────
Route::prefix('griffonVet')->group(function () {
    Route::post('/login',               [GriffonVetController::class, 'login']);
    Route::post('/usuarios/registro',   [GriffonVetController::class, 'registrarUsuario']);
    Route::get('/usuarios/activar',     [GriffonVetController::class, 'activarUsuario']);
    Route::post('/recuperar-password',  [GriffonVetController::class, 'recuperarPassword']);
    Route::post('/resetear-password',   [GriffonVetController::class, 'resetearPassword']);
    Route::get('/ObtenerNoticias',      [GriffonVetController::class, 'obtenerNoticias']);
    Route::get('/ObtenerEspecies',      [GriffonVetController::class, 'obtenerEspecies']);
    Route::get('/ObtenerServicios',     [GriffonVetController::class, 'obtenerServicios']);
    Route::get('/ObtenerInfoHome',      [GriffonVetController::class, 'obtenerInfoHome']);
    Route::get('/obtenerProductos',     [GriffonVetController::class, 'obtenerProductos']);
    
});

// ─── Protegidas con JWT ──────────────────────────────────────────────────────
Route::prefix('griffonVet')->middleware(JwtMiddleware::class)->group(function () {

    // Clientes y mascotas
    Route::post('/insertarClienteMascotaAdmin',         [GriffonVetController::class, 'insertarClienteMascotaAdmin']);
    Route::get('/obtenerClientes',                      [GriffonVetController::class, 'getClientes']);
    Route::post('/BusquedaClientes',                    [GriffonVetController::class, 'obtenerClientesConMascotas']);
    Route::post('/usuario/obtenerRecordatoriosMascotas',[GriffonVetController::class, 'obtenerRecordatoriosMascotas']);
    Route::post('/obtenerMascota',                      [GriffonVetController::class, 'getMascota']);
    Route::post('/insertarMascotas',                    [GriffonVetController::class, 'insertarMascota']);
    Route::put('/actualizarMascotas',                   [GriffonVetController::class, 'editarInfoGeneralMascota']);
    Route::get('/usuario/obtenerMascotas',              [GriffonVetController::class, 'obtenerMascotasPorUsuario']);
    // Consultas clínicas
    Route::post('/nuevaConsulta',               [GriffonVetController::class, 'insertarConsultaClinica']);
    Route::post('/ActualizarConsultaClinica',   [GriffonVetController::class, 'actualizarConsultaClinica']);
    Route::delete('/EliminarConsulta',          [GriffonVetController::class, 'eliminarConsulta']);

    // Categorías
    Route::get('/ObtenerCategorias',    [GriffonVetController::class, 'obtenerCategorias']);
    Route::post('/InsertarCategoria',   [GriffonVetController::class, 'insertarCategoria']);

    // Productos
    Route::post('/insertarProductos',   [GriffonVetController::class, 'insertarProducto']);
    Route::post('/actualizarProductos',  [GriffonVetController::class, 'actualizarProducto']);
    Route::delete('/EliminarProducto',  [GriffonVetController::class, 'eliminarProducto']);

    // Medicamentos
    Route::get('/ObtenerMedicamentos',      [GriffonVetController::class, 'obtenerMedicamentos']);
    Route::post('/InsertarMedicamento',     [GriffonVetController::class, 'insertarMedicamento']);

    // Vacunas
    Route::get('/ObtenerVacunas',       [GriffonVetController::class, 'obtenerVacunas']);
    Route::post('/InsertarVacuna',      [GriffonVetController::class, 'insertarVacuna']);
    Route::post('/InsertarVacunacion',  [GriffonVetController::class, 'insertarVacunacion']);

    // Desparasitación
    Route::get('/ObtenerDesparasitaciones',     [GriffonVetController::class, 'obtenerDesparasitaciones']);
    Route::post('/InsertarDesparasitacion',     [GriffonVetController::class, 'insertarDesparasitacion']);
    Route::post('/InsertarTipoDesparasitacion', [GriffonVetController::class, 'insertarDesparasitacionCatalogo']);

    // Peso
    Route::post('/InsertarPeso', [GriffonVetController::class, 'insertarPeso']);

    // Enfermedades
    Route::get('/ObtenerEnfermedades',          [GriffonVetController::class, 'obtenerEnfermedades']);
    Route::post('/InsertarEnfermedad',          [GriffonVetController::class, 'insertarEnfermedad']);
    Route::post('/InsertarEnfermedadCatalogo',  [GriffonVetController::class, 'insertarEnfermedadCatalogo']);

    // Alergias
    Route::get('/ObtenerAlergias',          [GriffonVetController::class, 'obtenerAlergias']);
    Route::post('/InsertarAlergia',         [GriffonVetController::class, 'insertarAlergia']);
    Route::post('/InsertarAlergiaCatalogo', [GriffonVetController::class, 'insertarAlergiaCatalogo']);

    // Servicios
    Route::put('/ActualizarServicio',           [GriffonVetController::class, 'actualizarServicio']);
    Route::delete('/EliminarServicio',          [GriffonVetController::class, 'eliminarServicio']);
    Route::post('/InsertarServicio',            [GriffonVetController::class, 'insertarServicio']);
    Route::post('/ObtenerServicioPorMascota',   [GriffonVetController::class, 'obtenerServicioPorMascota']);

    // Home
   
    Route::post('/InsertarInfoHome',    [GriffonVetController::class, 'insertarInfoHome']);
    Route::post('/ActualizarInfoHome',   [GriffonVetController::class, 'actualizarInfoHome']);
    Route::delete('/EliminarInfoHome',  [GriffonVetController::class, 'eliminarInfoHome']);

    // Dashboard
    Route::get('/admin/dashboard', [GriffonVetController::class, 'obtenerDashboardAdmin']);
});