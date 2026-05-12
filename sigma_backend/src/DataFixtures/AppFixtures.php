<?php
namespace App\DataFixtures;

use App\Entity\Dossier;
use App\Entity\Etape;
use App\Entity\User;
use App\Enum\StatutDossier;
use Doctrine\Bundle\FixturesBundle\Fixture;
use Doctrine\Persistence\ObjectManager;
use Symfony\Component\PasswordHasher\Hasher\UserPasswordHasherInterface;

class AppFixtures extends Fixture
{
    public function __construct(
        private UserPasswordHasherInterface $hasher
    ) {}

    public function load(ObjectManager $manager): void
    {
        // 1. Citoyen Kouassi Aya
        $citoyen = new User();
        $citoyen->setEmail('citoyen@sigma.ci');
        $citoyen->setNomComplet('Kouassi Aya');
        $citoyen->setRoles(['ROLE_CITOYEN']);
        $citoyen->setPassword(
            $this->hasher->hashPassword($citoyen, 'password123')
        );
        $manager->persist($citoyen);

        // 2. Citoyen Jean Marc
        $jeanMarc = new User();
        $jeanMarc->setEmail('jeanmarc@sigma.ci');
        $jeanMarc->setNomComplet('Jean Marc Koné');
        $jeanMarc->setRoles(['ROLE_CITOYEN']);
        $jeanMarc->setPassword(
            $this->hasher->hashPassword($jeanMarc, 'password123')
        );
        $manager->persist($jeanMarc);

        // 3. Agent
        $agent = new User();
        $agent->setEmail('agent@sigma.ci');
        $agent->setNomComplet('Coulibaly Seydou');
        $agent->setRoles(['ROLE_AGENT']);
        $agent->setPassword(
            $this->hasher->hashPassword($agent, 'password123')
        );
        $manager->persist($agent);

        // 4. Directeur — NOUVEAU
        $directeur = new User();
        $directeur->setEmail('directeur@sigma.ci');
        $directeur->setNomComplet('Diabaté Moussa');
        $directeur->setRoles(['ROLE_DIRECTEUR']);
        $directeur->setPassword(
            $this->hasher->hashPassword($directeur, 'password123')
        );
        $manager->persist($directeur);

        // 5. Étapes du workflow — mises à jour
        $etapesData = [
            ['Dépôt du dossier',       1, 'Guichet d\'accueil'],
            ['Vérification des pièces', 2, 'Service Scolarité'],
            ['Instruction du dossier',  3, 'Service Scolarité'],
            ['En attente de signature', 4, 'Direction'],
            ['Approuvé',               5, 'Direction'],
            ['Rejeté',                 6, 'Direction'],
            ['Prêt pour retrait',      7, 'Guichet d\'accueil'],
        ];

        foreach ($etapesData as [$libelle, $ordre, $service]) {
            $etape = new Etape();
            $etape->setLibelle($libelle);
            $etape->setOrdreSequence($ordre);
            $etape->setServiceResponsable($service);
            $manager->persist($etape);
        }

        // 6. Dossiers de test
        // Dossier en attente de signature — celui que le Directeur va traiter
        $dossier1 = new Dossier();
        $dossier1->setProprietaire($citoyen);
        $dossier1->setStatut(StatutDossier::SIGNATURE_DIR);
        $manager->persist($dossier1);

        // Dossier en analyse — pour tester l'interface Agent
        $dossier2 = new Dossier();
        $dossier2->setProprietaire($jeanMarc);
        $dossier2->setStatut(StatutDossier::EN_ANALYSE);
        $manager->persist($dossier2);

        // Dossier en analyse — pour tester l'interface Agent
        $dossier3 = new Dossier();
        $dossier3->setProprietaire($jeanMarc);
        $dossier3->setStatut(StatutDossier::SOUMIS);
        $manager->persist($dossier3);

        // 7. Token FCM
        $token = new \App\Entity\DeviceToken();
        $token->setToken('TOKEN_FCM_TEST_KOUASSI_AYA');
        $token->setDeviceType('android');
        $token->setLastSeen(new \DateTime());
        $token->setUser($citoyen);
        $manager->persist($token);

        $manager->flush();
    }
}
