<?php

declare(strict_types=1);

namespace DoctrineMigrations;

use Doctrine\DBAL\Schema\Schema;
use Doctrine\Migrations\AbstractMigration;

/**
 * Auto-generated Migration: Please modify to your needs!
 */
final class Version20260508120717 extends AbstractMigration
{
    public function getDescription(): string
    {
        return '';
    }

    public function up(Schema $schema): void
    {
        // this up() migration is auto-generated, please modify it to your needs
        $this->addSql('ALTER TABLE dossier DROP FOREIGN KEY `FK_3D48E037A831773D`');
        $this->addSql('DROP INDEX IDX_3D48E037A831773D ON dossier');
        $this->addSql('ALTER TABLE dossier ADD statut VARCHAR(255) NOT NULL, DROP statut_actuel_id');
    }

    public function down(Schema $schema): void
    {
        // this down() migration is auto-generated, please modify it to your needs
        $this->addSql('ALTER TABLE dossier ADD statut_actuel_id INT DEFAULT NULL, DROP statut');
        $this->addSql('ALTER TABLE dossier ADD CONSTRAINT `FK_3D48E037A831773D` FOREIGN KEY (statut_actuel_id) REFERENCES etape (id) ON UPDATE NO ACTION ON DELETE NO ACTION');
        $this->addSql('CREATE INDEX IDX_3D48E037A831773D ON dossier (statut_actuel_id)');
    }
}
