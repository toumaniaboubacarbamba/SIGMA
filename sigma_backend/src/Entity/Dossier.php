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
use App\State\RejeterDossierProcessor;
use Doctrine\ORM\Mapping as ORM;

#[ORM\Entity(repositoryClass: DossierRepository::class)]
#[ApiResource(
    operations: [
        new GetCollection(),
        new Get(security: "is_granted('DOSSIER_VIEW', object)"),
        new Post(),
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
    private ?int $id = null;

    #[ORM\Column(length: 50)]
    private ?string $numero_reference = null;

    #[ORM\Column]
    private ?\DateTime $date_depot = null;

    #[ORM\Column(type: 'string', enumType: StatutDossier::class)]
    private StatutDossier $statut = StatutDossier::BROUILLON;

    #[ORM\ManyToOne]
    #[ORM\JoinColumn(nullable: false)]
    private ?User $proprietaire = null;

    #[ORM\Column(length: 500, nullable: true)]
private ?string $motif_rejet = null;

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
}
