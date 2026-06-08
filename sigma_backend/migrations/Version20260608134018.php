<?php

declare(strict_types=1);

namespace DoctrineMigrations;

use Doctrine\DBAL\Schema\Schema;
use Doctrine\Migrations\AbstractMigration;

/**
 * Auto-generated Migration: Please modify to your needs!
 */
final class Version20260608134018 extends AbstractMigration
{
    public function getDescription(): string
    {
        return 'Ajoute les champs description, categorie_ia et score_confiance_ia a la table dossier (module IA de classification).';
    }

    public function up(Schema $schema): void
    {
        // this up() migration is auto-generated, please modify it to your needs
        $this->addSql('ALTER TABLE dossier ADD description LONGTEXT DEFAULT NULL, ADD categorie_ia VARCHAR(50) DEFAULT NULL, ADD score_confiance_ia DOUBLE PRECISION DEFAULT NULL');
    }

    public function down(Schema $schema): void
    {
        // this down() migration is auto-generated, please modify it to your needs
        $this->addSql('ALTER TABLE dossier DROP description, DROP categorie_ia, DROP score_confiance_ia');
    }
}
