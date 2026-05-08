<?php

namespace App\Enum;

enum StatutDossier: string
{
    case BROUILLON     = 'BROUILLON';
    case SOUMIS        = 'SOUMIS';
    case EN_ANALYSE    = 'EN_ANALYSE';
    case INCOMPLET     = 'INCOMPLET';
    case RECEVABLE     = 'RECEVABLE';
    case SIGNATURE_DIR = 'SIGNATURE_DIR';
    case APPROUVE      = 'APPROUVE';
    case REJETE        = 'REJETE';
}
