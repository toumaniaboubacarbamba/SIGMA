<?php

namespace App\Message;

class SendNotificationMessage {

    public function __construct(
        private string $deviceToken,
        private string $title,
        private string $body,
        private array $data = []
    )
    {}

    public function getDeviceToken(): string { return $this->deviceToken;}
    public function getTitle(): string { return $this->title;}
    public function getBody(): string { return $this->body;}
    public function getData(): array { return $this->data;}
}
