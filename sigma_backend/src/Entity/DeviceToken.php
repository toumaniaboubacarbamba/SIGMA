<?php

namespace App\Entity;

use ApiPlatform\Metadata\ApiResource;
use ApiPlatform\Metadata\Patch;
use ApiPlatform\Metadata\Post;
use App\Repository\DeviceTokenRepository;
use Doctrine\ORM\Mapping as ORM;

#[ORM\Entity(repositoryClass: DeviceTokenRepository::class)]
#[ApiResource(
    operations:[
        new Post(),
        new Patch()
    ]
)]
class DeviceToken
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column]
    private ?int $id = null;

    #[ORM\Column(length: 255)]
    private ?string $token = null;

    #[ORM\Column(length: 20)]
    private ?string $device_type = null;

    #[ORM\Column(nullable: true)]
    private ?\DateTime $last_seen = null;

    #[ORM\ManyToOne]
    #[ORM\JoinColumn(nullable: false)]
    private ?User $user = null;

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getToken(): ?string
    {
        return $this->token;
    }

    public function setToken(string $token): static
    {
        $this->token = $token;

        return $this;
    }

    public function getDeviceType(): ?string
    {
        return $this->device_type;
    }

    public function setDeviceType(string $device_type): static
    {
        $this->device_type = $device_type;

        return $this;
    }

    public function getLastSeen(): ?\DateTime
    {
        return $this->last_seen;
    }

    public function setLastSeen(?\DateTime $last_seen): static
    {
        $this->last_seen = $last_seen;

        return $this;
    }

    public function getUser(): ?User
    {
        return $this->user;
    }

    public function setUser(?User $user): static
    {
        $this->user = $user;

        return $this;
    }
}
