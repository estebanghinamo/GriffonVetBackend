<?php

namespace App\Http\Middleware;

use Closure;
use Exception;
use Firebase\JWT\JWT;
use Firebase\JWT\Key;
use Illuminate\Http\Request;

class JwtMiddleware
{
    public function handle(Request $request, Closure $next)
    {
        $token = $request->bearerToken();

        if (!$token) {
            return response()->json(['success' => 0, 'mensaje' => 'Token no proporcionado'], 401);
        }

        try {
            $decoded = JWT::decode($token, new Key(config('app.jwt_secret'), 'HS256'));
            $request->attributes->set('jwt_payload', $decoded);
        } catch (Exception $e) {
            return response()->json(['success' => 0, 'mensaje' => 'Token inválido o expirado'], 401);
        }

        return $next($request);
    }
}
