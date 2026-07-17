<?php

declare(strict_types=1);

namespace Declined\Resources;

use Declined\ApiPaths;
use Declined\HttpTransport;

final class EventsResource
{
    public function __construct(private readonly HttpTransport $http)
    {
    }

    public function create(array $params): mixed
    {
        return $this->http->request('POST', ApiPaths::EVENTS, $params);
    }

    public function markPaymentRecovered(array $params): mixed
    {
        return $this->create(array_merge($params, ['type' => 'payment_recovered']));
    }
}

final class CustomersResource
{
    public function __construct(private readonly HttpTransport $http)
    {
    }

    public function list(array $params = []): mixed
    {
        return $this->http->request('GET', ApiPaths::CUSTOMERS, null, $params);
    }
}

final class RecoveriesResource
{
    public function __construct(private readonly HttpTransport $http)
    {
    }

    public function list(array $params = []): mixed
    {
        return $this->http->request('GET', ApiPaths::RECOVERIES, null, $params);
    }

    public function markRecovered(string $recoveryAttemptId): mixed
    {
        return $this->http->request('POST', ApiPaths::recoveryMarkRecovered($recoveryAttemptId));
    }
}

final class SequencesResource
{
    public function __construct(private readonly HttpTransport $http)
    {
    }

    public function list(array $params = []): mixed
    {
        return $this->http->request('GET', ApiPaths::SEQUENCES, null, $params);
    }
}

final class WebhooksResource
{
    public function __construct(private readonly HttpTransport $http)
    {
    }

    public function list(array $params = []): mixed
    {
        return $this->http->request('GET', ApiPaths::WEBHOOKS, null, $params);
    }
}

final class IncentivesResource
{
    public function __construct(private readonly HttpTransport $http)
    {
    }

    public function list(array $params = []): mixed
    {
        return $this->http->request('GET', ApiPaths::INCENTIVES, null, $params);
    }
}

final class AnalyticsResource
{
    public function __construct(private readonly HttpTransport $http)
    {
    }

    public function get(array $params = []): mixed
    {
        return $this->http->request('GET', ApiPaths::ANALYTICS, null, $params);
    }
}
