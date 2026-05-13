<?php

namespace App\Controller\Admin;

use App\Entity\User;
use App\Repository\UserRepository;
use Doctrine\ORM\EntityManagerInterface;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\PasswordHasher\Hasher\UserPasswordHasherInterface;
use Symfony\Component\Routing\Attribute\Route;


#[Route('/admin', name: 'admin_')]
class UserAdminController extends AbstractController
{
    public function __construct(
        private EntityManagerInterface $em,
        private UserRepository $userRepository,
        private UserPasswordHasherInterface $passwordHasher
    ) {}

    #[Route('/users', name: 'users_list', methods: ['GET'])]
    public function list(): Response
    {
        $users = $this->userRepository->findBy(
            [],
            ['nom_complet' => 'ASC']
        );

        return $this->render('admin/users/list.html.twig', [
            'users' => $users,
        ]);
    }

    #[Route('/users/new', name: 'users_new', methods: ['GET', 'POST'])]
    public function new(Request $request): Response
    {
        if ($request->isMethod('POST')) {
            $user = new User();
            $user->setEmail($request->request->get('email'));
            $user->setNomComplet($request->request->get('nom_complet'));
            $user->setTelephone($request->request->get('telephone'));
            $user->setRoles([$request->request->get('role')]);
            $user->setPassword(
                $this->passwordHasher->hashPassword($user, $request->request->get('password'))
            );
            $user->setCreatedBy($this->getUser());

            $this->em->persist($user);
            $this->em->flush();

            $this->addFlash('success', 'Compte créé avec succès.');
            return $this->redirectToRoute('admin_users_list');
        }

        return $this->render('admin/users/new.html.twig');
    }

    #[Route('/users/{id}/toggle-status', name: 'users_toggle_status', methods: ['POST'])]
    public function toggleStatus(User $user): Response
    {
        if ($user === $this->getUser()) {
            $this->addFlash('error', 'Vous ne pouvez pas désactiver votre propre compte.');
            return $this->redirectToRoute('admin_users_list');
        }

        $user->setIsActive(!$user->isActive());
        $this->em->flush();

        $status = $user->isActive() ? 'activé' : 'désactivé';
        $this->addFlash('success', "Compte {$status} avec succès.");

        return $this->redirectToRoute('admin_users_list');
    }

    #[Route('/users/{id}/role', name: 'users_change_role', methods: ['POST'])]
    public function changeRole(User $user, Request $request): Response
    {
        $newRole = $request->request->get('role');
        $allowedRoles = ['ROLE_AGENT', 'ROLE_DIRECTEUR', 'ROLE_ADMIN'];

        if (!in_array($newRole, $allowedRoles)) {
            $this->addFlash('error', 'Rôle invalide.');
            return $this->redirectToRoute('admin_users_list');
        }

        $user->setRoles([$newRole]);
        $this->em->flush();

        $this->addFlash('success', 'Rôle mis à jour.');
        return $this->redirectToRoute('admin_users_list');
    }


}
