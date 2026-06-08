<?php

namespace App\Entity;

use ApiPlatform\Metadata\ApiResource;
use ApiPlatform\Metadata\Get;
use ApiPlatform\Metadata\GetCollection;
use ApiPlatform\Metadata\Patch;
use ApiPlatform\Metadata\Post;
use App\Enum\StatutDossier;
use App\Repository\DossierRepository;
use App\State\ApprouverDossierProcessor;
use App\State\CreateDossierProcessor;
use App\State\RejeterDossierProcessor;
use Doctrine\DBAL\Types\Types;
use Doctrine\ORM\Mapping as ORM;
use Symfony\Component\Serializer\Attribute\Groups;

#[ORM\Entity(repositoryClass: DossierRepository::class)]
#[ApiResource(
    normalizationContext: ['groups' => ['dossier:read']],
    denormalizationContext: ['groups' => ['dossier:write']],
    operations: [
        new GetCollection(),
        new Get(security: "is_granted('DOSSIER_VIEW', object)"),
        new Post(processor: CreateDossierProcessor::class),
        new Patch(security: "is_granted('DOSSIER_EDIT', object)"),

        new Post(
            uriTemplate:'/dossiers/{id}/approuver',
            requirements: ['id' => '\d+'],
            security: "is_granted('DOSSIER_EDIT', object)",
            processor: ApprouverDossierProcessor::class,
            name: 'approuver_dossier'
        ),
        new Post(
            uriTemplate:'/dossiers/{id}/rejeter',
            requirements: ['id' => '\d+'],
            security: "is_granted('DOSSIER_EDIT', object)",
            processor: RejeterDossierProcessor::class,
            name: 'rejeter_dossier'
        ),
    ]
)]
#[ORM\HasLifecycleCallbacks]
class Dossier
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column]
    #[Groups(['dossier:read'])]
    private ?int $id = null;

    #[ORM\Column(length: 50)]
    #[Groups(['dossier:read'])]
    private ?string $numero_reference = null;

    #[ORM\Column]
    #[Groups(['dossier:read'])]
    private ?\DateTime $date_depot = null;

    #[ORM\Column(type: 'string', enumType: StatutDossier::class)]
    #[Groups(['dossier:read'])]
    private StatutDossier $statut = StatutDossier::BROUILLON;

    #[ORM\ManyToOne]
    #[ORM\JoinColumn(nullable: false)]
    #[Groups(['dossier:read'])]
    private ?User $proprietaire = null;

    #[ORM\Column(length: 500, nullable: true)]
    #[Groups(['dossier:read'])]
    private ?string $motif_rejet = null;

    #[ORM\Column(type: Types::TEXT, nullable: true)]
    #[Groups(['dossier:read', 'dossier:write'])]
    private ?string $description = null;

    #[ORM\Column(length: 50, nullable: true)]
    #[Groups(['dossier:read'])]
    private ?string $categorieIa = null;

    #[ORM\Column(type: Types::FLOAT, nullable: true)]
    #[Groups(['dossier:read'])]
    private ?float $scoreConfianceIa = null;

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

    public function getStatut(): StatutDossier
    {
        return $this->statut;
    }

    public function setStatut(StatutDossier $statut): static
    {
        $this->statut = $statut;

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

    public function getMotifRejet(): ?string{
        return $this->motif_rejet;
    }

    public function setMotifRejet(?string $motif_rejet): static{
        $this->motif_rejet = $motif_rejet;
        return $this;
    }

    public function getDescription(): ?string
    {
        return $this->description;
    }

    public function setDescription(?string $description): static
    {
        $this->description = $description;

        return $this;
    }

    public function getCategorieIa(): ?string
    {
        return $this->categorieIa;
    }

    public function setCategorieIa(?string $categorieIa): static
    {
        $this->categorieIa = $categorieIa;

        return $this;
    }

    public function getScoreConfianceIa(): ?float
    {
        return $this->scoreConfianceIa;
    }

    public function setScoreConfianceIa(?float $scoreConfianceIa): static
    {
        $this->scoreConfianceIa = $scoreConfianceIa;

        return $this;
    }
}
