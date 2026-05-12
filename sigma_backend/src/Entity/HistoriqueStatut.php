<?php

namespace App\Entity;

use ApiPlatform\Metadata\ApiResource;
use ApiPlatform\Metadata\Get;
use ApiPlatform\Metadata\GetCollection;
use ApiPlatform\Metadata\Post;
use App\Enum\StatutDossier;
use App\Repository\HistoriqueStatutRepository;
use Doctrine\DBAL\Types\Types;
use Doctrine\ORM\Mapping as ORM;

#[ORM\Entity(repositoryClass: HistoriqueStatutRepository::class)]
#[ApiResource(
    operations:[
        new GetCollection(),
        new Get(),
        new Post()
    ]
)]
class HistoriqueStatut
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column]
    private ?int $id = null;

    #[ORM\Column]
    private ?\DateTime $date_entree = null;

    #[ORM\Column(nullable: true)]
    private ?\DateTime $date_sortie = null;

    #[ORM\Column(type: Types::TEXT, nullable: true)]
    private ?string $commentaire_agent = null;

    #[ORM\ManyToOne]
    #[ORM\JoinColumn(nullable: false)]
    private ?Dossier $dossier = null;

    #[ORM\Column(type: 'string', enumType: StatutDossier::class, nullable: true)]
    private ?StatutDossier $statut = null;

    #[ORM\ManyToOne]
    #[ORM\JoinColumn(nullable: true)]
    private ?Etape $etape = null;

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getDateEntree(): ?\DateTime
    {
        return $this->date_entree;
    }

    public function setDateEntree(\DateTime $date_entree): static
    {
        $this->date_entree = $date_entree;

        return $this;
    }

    public function getDateSortie(): ?\DateTime
    {
        return $this->date_sortie;
    }

    public function setDateSortie(?\DateTime $date_sortie): static
    {
        $this->date_sortie = $date_sortie;

        return $this;
    }

    public function getCommentaireAgent(): ?string
    {
        return $this->commentaire_agent;
    }

    public function setCommentaireAgent(?string $commentaire_agent): static
    {
        $this->commentaire_agent = $commentaire_agent;

        return $this;
    }

    public function getDossier(): ?Dossier
    {
        return $this->dossier;
    }

    public function setDossier(?Dossier $dossier): static
    {
        $this->dossier = $dossier;

        return $this;
    }

    public function getStatut(): ?StatutDossier
    {
        return $this->statut;
    }

    public function setStatut(?StatutDossier $statut): static
    {
        $this->statut = $statut;

        return $this;
    }

    public function getEtape(): ?Etape
    {
        return $this->etape;
    }

    public function setEtape(?Etape $etape): static
    {
        $this->etape = $etape;

        return $this;
    }
}
