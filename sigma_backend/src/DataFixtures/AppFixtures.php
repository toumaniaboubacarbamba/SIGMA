<?php
namespace App\DataFixtures;

use App\Entity\Etape;
use App\Entity\User;
use Doctrine\Bundle\FixturesBundle\Fixture;
use Doctrine\Persistence\ObjectManager;
use Symfony\Component\PasswordHasher\Hasher\UserPasswordHasherInterface;

class AppFixtures extends Fixture
{
    // Injection du service de hachage de mot de passe
     public function __construct(
        private UserPasswordHasherInterface $hasher
    ) {}

    public function load(ObjectManager $manager): void
    {
        // 1. Citoyen
        $citoyen = new User();
        $citoyen->setEmail('citoyen@sigma.ci');
        $citoyen->setNomComplet('Kouassi Aya');
        $citoyen->setRoles(['ROLE_CITOYEN']);
        $citoyen->setPassword(
            $this->hasher->hashPassword($citoyen, 'password123')
        );
        $manager->persist($citoyen);

        // 2. Citoyen
        $jeanMarc = new User();
        $jeanMarc->setEmail('jeanmarc@sigma.ci');
        $jeanMarc->setNomComplet('Jean Marc Koné');
        $jeanMarc->setRoles(['ROLE_CITOYEN']);
        $jeanMarc->setPassword(
            $this->hasher->hashPassword($jeanMarc, 'password123')
        );
        $manager->persist($jeanMarc);

        // 2. Agent
        $agent = new User();
        $agent->setEmail('agent@sigma.ci');
        $agent->setNomComplet('Coulibaly Seydou');
        $agent->setRoles(['ROLE_AGENT']);
        $agent->setPassword(
            $this->hasher->hashPassword($agent, 'password123')
        );
        $manager->persist($agent);

        // 3. Étapes du workflow
        $etapes = [
            ['Dépôt du dossier', 1, 'Guichet d\'accueil'],
            ['Vérification des pièces', 2, 'Service Scolarité'],
            ['Transmission au Directeur', 3, 'Secrétariat'],
            ['Visa du Directeur', 4, 'Direction'],
            ['Prêt pour retrait', 5, 'Guichet d\'accueil'],
        ];

        foreach ($etapes as [$libelle, $ordre, $service]) {
            $etape = new Etape();
            $etape->setLibelle($libelle);
            $etape->setOrdreSequence($ordre);
            $etape->setServiceResponsable($service);
            $manager->persist($etape);
        }

        // Token de test pour Kouassi Aya
$token = new \App\Entity\DeviceToken();
$token->setToken('TOKEN_FCM_TEST_KOUASSI_AYA');
$token->setDeviceType('android');
$token->setLastSeen(new \DateTime());
$token->setUser($citoyen);
$manager->persist($token);

        $manager->flush();
    }
}
