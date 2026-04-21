<?php

declare(strict_types=1);

namespace DoctrineMigrations;

use Doctrine\DBAL\Schema\Schema;
use Doctrine\Migrations\AbstractMigration;

/**
 * Auto-generated Migration: Please modify to your needs!
 */
final class Version20260420101446 extends AbstractMigration
{
    public function getDescription(): string
    {
        return '';
    }

    public function up(Schema $schema): void
    {
        // this up() migration is auto-generated, please modify it to your needs
        $this->addSql('CREATE TABLE device_token (id INT AUTO_INCREMENT NOT NULL, token VARCHAR(255) NOT NULL, device_type VARCHAR(20) NOT NULL, last_seen DATETIME DEFAULT NULL, user_id INT NOT NULL, INDEX IDX_99B2415CA76ED395 (user_id), PRIMARY KEY (id)) DEFAULT CHARACTER SET utf8mb4');
        $this->addSql('CREATE TABLE dossier (id INT AUTO_INCREMENT NOT NULL, numero_reference VARCHAR(50) NOT NULL, date_depot DATETIME NOT NULL, statut_actuel_id INT DEFAULT NULL, proprietaire_id INT NOT NULL, INDEX IDX_3D48E037A831773D (statut_actuel_id), INDEX IDX_3D48E03776C50E4A (proprietaire_id), PRIMARY KEY (id)) DEFAULT CHARACTER SET utf8mb4');
        $this->addSql('CREATE TABLE etape (id INT AUTO_INCREMENT NOT NULL, libelle VARCHAR(255) NOT NULL, ordre_sequence INT NOT NULL, service_responsable VARCHAR(255) NOT NULL, PRIMARY KEY (id)) DEFAULT CHARACTER SET utf8mb4');
        $this->addSql('CREATE TABLE historique_statut (id INT AUTO_INCREMENT NOT NULL, date_entree DATETIME NOT NULL, date_sortie DATETIME DEFAULT NULL, commentaire_agent LONGTEXT DEFAULT NULL, dossier_id INT NOT NULL, etape_id INT NOT NULL, INDEX IDX_2C2650E3611C0C56 (dossier_id), INDEX IDX_2C2650E34A8CA2AD (etape_id), PRIMARY KEY (id)) DEFAULT CHARACTER SET utf8mb4');
        $this->addSql('CREATE TABLE user (id INT AUTO_INCREMENT NOT NULL, email VARCHAR(180) NOT NULL, roles JSON NOT NULL, password VARCHAR(255) NOT NULL, nom_complet VARCHAR(255) NOT NULL, telephone VARCHAR(20) DEFAULT NULL, UNIQUE INDEX UNIQ_IDENTIFIER_EMAIL (email), PRIMARY KEY (id)) DEFAULT CHARACTER SET utf8mb4');
        $this->addSql('CREATE TABLE messenger_messages (id BIGINT AUTO_INCREMENT NOT NULL, body LONGTEXT NOT NULL, headers LONGTEXT NOT NULL, queue_name VARCHAR(190) NOT NULL, created_at DATETIME NOT NULL, available_at DATETIME NOT NULL, delivered_at DATETIME DEFAULT NULL, INDEX IDX_75EA56E0FB7336F0E3BD61CE16BA31DBBF396750 (queue_name, available_at, delivered_at, id), PRIMARY KEY (id)) DEFAULT CHARACTER SET utf8mb4');
        $this->addSql('ALTER TABLE device_token ADD CONSTRAINT FK_99B2415CA76ED395 FOREIGN KEY (user_id) REFERENCES user (id)');
        $this->addSql('ALTER TABLE dossier ADD CONSTRAINT FK_3D48E037A831773D FOREIGN KEY (statut_actuel_id) REFERENCES etape (id)');
        $this->addSql('ALTER TABLE dossier ADD CONSTRAINT FK_3D48E03776C50E4A FOREIGN KEY (proprietaire_id) REFERENCES user (id)');
        $this->addSql('ALTER TABLE historique_statut ADD CONSTRAINT FK_2C2650E3611C0C56 FOREIGN KEY (dossier_id) REFERENCES dossier (id)');
        $this->addSql('ALTER TABLE historique_statut ADD CONSTRAINT FK_2C2650E34A8CA2AD FOREIGN KEY (etape_id) REFERENCES etape (id)');
    }

    public function down(Schema $schema): void
    {
        // this down() migration is auto-generated, please modify it to your needs
        $this->addSql('ALTER TABLE device_token DROP FOREIGN KEY FK_99B2415CA76ED395');
        $this->addSql('ALTER TABLE dossier DROP FOREIGN KEY FK_3D48E037A831773D');
        $this->addSql('ALTER TABLE dossier DROP FOREIGN KEY FK_3D48E03776C50E4A');
        $this->addSql('ALTER TABLE historique_statut DROP FOREIGN KEY FK_2C2650E3611C0C56');
        $this->addSql('ALTER TABLE historique_statut DROP FOREIGN KEY FK_2C2650E34A8CA2AD');
        $this->addSql('DROP TABLE device_token');
        $this->addSql('DROP TABLE dossier');
        $this->addSql('DROP TABLE etape');
        $this->addSql('DROP TABLE historique_statut');
        $this->addSql('DROP TABLE user');
        $this->addSql('DROP TABLE messenger_messages');
    }
}
