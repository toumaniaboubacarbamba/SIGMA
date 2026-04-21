<?php

namespace App\Entity;

use ApiPlatform\Metadata\ApiResource;
use ApiPlatform\Metadata\Get;
use ApiPlatform\Metadata\GetCollection;
use ApiPlatform\Metadata\Patch;
use ApiPlatform\Metadata\Post;
use App\Repository\DossierRepository;
use Doctrine\ORM\Mapping as ORM;

#[ORM\Entity(repositoryClass: DossierRepository::class)]
#[ApiResource(
    operations: [
        new GetCollection(),
        new Get(),
        new Post(),
        new Patch(),
    ]
)]
#[ORM\HasLifecycleCallbacks]
class Dossier
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column]
    private ?int $id = null;

    #[ORM\Column(length: 50)]
    private ?string $numero_reference = null;

    #[ORM\Column]
    private ?\DateTime $date_depot = null;

    #[ORM\ManyToOne]
    private ?Etape $statut_actuel = null;

    #[ORM\ManyToOne]
    #[ORM\JoinColumn(nullable: false)]
    private ?User $proprietaire = null;

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getNumeroReference(): ?string
    {
        return $this->numero_reference;
    }

    public function setNumeroReference(string $numero_reference): static
    {
        $this->numero_reference = $numero_reference;

        return $this;
    }

    public function getDateDepot(): ?\DateTime
    {
        return $this->date_depot;
    }

    public function setDateDepot(\DateTime $date_depot): static
    {
        $this->date_depot = $date_depot;

        return $this;
    }

    public function getStatutActuel(): ?Etape
    {
        return $this->statut_actuel;
    }

    public function setStatutActuel(?Etape $statut_actuel): static
    {
        $this->statut_actuel = $statut_actuel;

        return $this;
    }

    public function getProprietaire(): ?User
    {
        return $this->proprietaire;
    }

    public function setProprietaire(?User $proprietaire): static
    {
        $this->proprietaire = $proprietaire;

        return $this;
    }

    #[ORM\PrePersist]
    public function setDateDepotAutomatique(): void
    {
        $this->date_depot = new \DateTime();
    }
}
