<?php

namespace App\Controller;

use App\Entity\User;
use Doctrine\ORM\EntityManagerInterface;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\PasswordHasher\Hasher\UserPasswordHasherInterface;
use Symfony\Component\Routing\Attribute\Route;
use Symfony\Component\Validator\Validator\ValidatorInterface;

final class RegistrationController extends AbstractController
{
    #[Route('/api/register', name: 'app_register', methods: ['POST'])]
    public function register(
        Request $request,
        UserPasswordHasherInterface $hasher,
        EntityManagerInterface $em,
        ValidatorInterface $validator
    ): JsonResponse {
        $data = json_decode($request->getContent(), true);

        if(!isset($data['email'], $data['password'], $data['nom_complet'])){
            return $this->json([
                'message'=>'Champs obligatoires manquants : email, password, nom_complet'
                ], 400);
        }

        $user = new User();
        $user->setEmail($data['email']);
        $user->setNomComplet($data['nom_complet']);
        $user->setTelephone($data['telephone'] ?? null);
        $user->setRoles(['ROLE_CITOYEN']);
        $user->setPassword(
            $hasher->hashPassword($user, $data['password'])
            );

        $errors = $validator->validate($user);
        if (count($errors) > 0){
            return $this->json([
                'message'=> (string) $errors
            ], 422);
        }

        $em->persist($user);
        $em->flush();

        return $this->json([
            'message'=> 'Compte créé avec succès',
            'email'=> $user->getEmail(),
        ], 201);
    }
}
