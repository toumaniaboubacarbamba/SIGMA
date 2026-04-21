<?php

namespace App\Entity;

use ApiPlatform\Metadata\ApiResource;
use ApiPlatform\Metadata\Get;
use ApiPlatform\Metadata\GetCollection;
use App\Repository\EtapeRepository;
use Doctrine\ORM\Mapping as ORM;

#[ORM\Entity(repositoryClass: EtapeRepository::class)]
#[ApiResource(
    operations:[
        new GetCollection(),
        new Get()
    ]
)]
class Etape
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column]
    private ?int $id = null;

    #[ORM\Column(length: 255)]
    private ?string $libelle = null;

    #[ORM\Column]
    private ?int $ordre_sequence = null;

    #[ORM\Column(length: 255)]
    private ?string $service_responsable = null;

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getLibelle(): ?string
    {
        return $this->libelle;
    }

    public function setLibelle(string $libelle): static
    {
        $this->libelle = $libelle;

        return $this;
    }

    public function getOrdreSequence(): ?int
    {
        return $this->ordre_sequence;
    }

    public function setOrdreSequence(int $ordre_sequence): static
    {
        $this->ordre_sequence = $ordre_sequence;

        return $this;
    }

    public function getServiceResponsable(): ?string
    {
        return $this->service_responsable;
    }

    public function setServiceResponsable(string $service_responsable): static
    {
        $this->service_responsable = $service_responsable;

        return $this;
    }
}
