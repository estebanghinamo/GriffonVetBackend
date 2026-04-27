<?php

namespace App\Services;

use Exception;
use Firebase\JWT\JWT;
use Firebase\JWT\Key;
use Illuminate\Http\Request;

class JsonUtils
{
    private Request $request;

    public function __construct(Request $request)
    {
        $this->request = $request;
    }

    public function getPayload(): object
    {
        $payload = $this->request->attributes->get('jwt_payload');
        if (!$payload) {
            throw new Exception('JWT payload no disponible');
        }
        return $payload;
    }

    public function getIdUsuario(): ?int
    {
        $payload = $this->getPayload();
        return isset($payload->id_usuario) ? (int) $payload->id_usuario : null;
    }

    public function getRol(): ?string
    {
        $payload = $this->getPayload();
        return $payload->rol ?? null;
    }

    public function inyectarClaim(string|null $json, string $campo, mixed $valor): string
    {
        $data = ($json === null || trim($json) === '') ? [] : json_decode($json, true);
        $data[$campo] = $valor;
        return json_encode($data);
    }

    public function resolverIdUsuario(string $json): string
    {
        $payload = $this->getPayload();
        if (($payload->rol ?? '') === 'ADMIN') {
            return $json;
        }
        return $this->inyectarClaim($json, 'id_usuario', $this->getIdUsuario());
    }

    public function jsonSoloConIdUsuario(): string
    {
        return $this->inyectarClaim(null, 'id_usuario', $this->getIdUsuario());
    }
}
