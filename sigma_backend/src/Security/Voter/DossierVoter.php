<?php

namespace App\Security\Voter;

use App\Enum\StatutDossier;
use App\Entity\Dossier;
use App\Entity\User;
use Symfony\Component\Security\Core\Authentication\Token\TokenInterface;
use Symfony\Component\Security\Core\Authorization\Voter\Voter;

class DossierVoter extends Voter
{
    public const VIEW = 'DOSSIER_VIEW';
    public const EDIT = 'DOSSIER_EDIT';

    // On vérifie d'abord si l'attribut et le sujet sont supportés par ce voter
    protected function supports(string $attribute, mixed $subject): bool
    {
        return in_array($attribute, [self::VIEW, self::EDIT])
            && $subject instanceof Dossier;
    }

    // Si supports() retourne true, on entre dans cette méthode pour vérifier les permissions
    protected function voteOnAttribute(string $attribute, mixed $subject, TokenInterface $token): bool
    {
        $user = $token->getUser();

        if (!$user instanceof User) {
            return false;
        }

        /** @var Dossier $dossier */
        $dossier = $subject;

        return match($attribute) {
            self::VIEW => $this->canView($dossier, $user),
            self::EDIT => $this->canEdit($dossier, $user),
            default => false,
        };
    }

    private function canView(Dossier $dossier, User $user): bool
    {
        // Agent et Directeur voient tout
        if (in_array('ROLE_AGENT', $user->getRoles()) ||
            in_array('ROLE_DIRECTEUR', $user->getRoles())) {
            return true;
        }

        // Citoyen ne voit que ses propres dossiers
        return $dossier->getProprietaire() === $user;
    }

    private function canEdit(Dossier $dossier, User $user): bool
{
    if (in_array('ROLE_AGENT', $user->getRoles())) {
        return true;
    }

    if (in_array('ROLE_DIRECTEUR', $user->getRoles())) {
        return $dossier->getStatut() === StatutDossier::SIGNATURE_DIR;
    }

    return false;
}
}
