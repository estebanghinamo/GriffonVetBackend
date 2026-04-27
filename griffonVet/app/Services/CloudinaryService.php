<?php

namespace App\Services;

use Cloudinary\Cloudinary;
use Cloudinary\Configuration\Configuration;
use Cloudinary\Api\Upload\UploadApi;
use Illuminate\Http\UploadedFile;

class CloudinaryService
{
    private UploadApi $uploader;

    public function __construct()
    {
        Configuration::instance([
            'cloud' => [
                'cloud_name' => config('services.cloudinary.cloud_name'),
                'api_key'    => config('services.cloudinary.api_key'),
                'api_secret' => config('services.cloudinary.api_secret'),
            ],
        ]);

        $this->uploader = new UploadApi();
    }

    public function subirArchivo(UploadedFile $file): string
    {
        $result = $this->uploader->upload(
            $file->getRealPath(),
            ['resource_type' => 'auto']
        );

        return $result['secure_url'];
    }
}
