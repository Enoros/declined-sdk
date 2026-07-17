<?php

declare(strict_types=1);

namespace Declined;

final class ApiPaths
{
    public const EVENTS = '/v1/events';
    public const CUSTOMERS = '/v1/customers';
    public const RECOVERIES = '/v1/recoveries';
    public const SEQUENCES = '/v1/sequences';
    public const WEBHOOKS = '/v1/webhooks';
    public const ANALYTICS = '/v1/analytics';
    public const INCENTIVES = '/v1/incentives';

    public const DEFAULT_BASE_URL = 'https://api.declined.io/api';

    public static function recoveryMarkRecovered(string $id): string
    {
        return '/v1/recoveries/' . $id . '/mark-recovered';
    }

    public static function buildUrl(string $baseUrl, string $path): string
    {
        return rtrim($baseUrl, '/') . $path;
    }
}
