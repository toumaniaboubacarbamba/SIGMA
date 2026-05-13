<?php

namespace App\Controller\Admin;

use App\Entity\User;
use Doctrine\ORM\EntityManagerInterface;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\Routing\Attribute\Route;

#[Route('/api/admin', name: 'api_admin_')]
class UserAdminApiController extends AbstractController
{
    public function __construct(
        private EntityManagerInterface $em
    ) {}

    #[Route('/users/{id}/toggle-status', name: 'toggle_status', methods: ['PATCH'])]
    public function toggleStatus(User $user): JsonResponse
    {
        if (!$this->isGranted('ROLE_ADMIN')) {
            return $this->json(['error' => 'Accès refusé.'], 403);
        }

        if ($user === $this->getUser()) {
            return $this->json(['error' => 'Vous ne pouvez pas désactiver votre propre compte.'], 400);
        }

        $user->setIsActive(!$user->isActive());
        $this->em->flush();

        return $this->json([
            'id'       => $user->getId(),
            'email'    => $user->getEmail(),
            'isActive' => $user->isActive(),
            'message'  => $user->isActive() ? 'Compte activé.' : 'Compte désactivé.',
        ]);
    }
}
