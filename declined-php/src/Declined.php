<?php

declare(strict_types=1);

namespace Declined;

use Declined\Resources\AnalyticsResource;
use Declined\Resources\CustomersResource;
use Declined\Resources\EventsResource;
use Declined\Resources\IncentivesResource;
use Declined\Resources\RecoveriesResource;
use Declined\Resources\SequencesResource;
use Declined\Resources\WebhooksResource;
use GuzzleHttp\Client as GuzzleClient;
use GuzzleHttp\ClientInterface;

final class HttpTransport
{
    public function __construct(
        private readonly string $apiKey,
        private readonly string $baseUrl,
        private readonly ClientInterface $http,
    ) {
    }

    public function request(string $method, string $path, ?array $body = null, ?array $query = null): mixed
    {
        $options = [
            'headers' => [
                'Authorization' => 'Bearer ' . $this->apiKey,
                'Content-Type' => 'application/json',
                'Accept' => 'application/json',
            ],
        ];
        if ($body !== null) {
            $options['json'] = $body;
        }
        if ($query !== null) {
            $options['query'] = array_filter($query, static fn ($v) => $v !== null);
        }

        $response = $this->http->request($method, ApiPaths::buildUrl($this->baseUrl, $path), $options);
        $status = $response->getStatusCode();
        $text = (string) $response->getBody();
        $data = $text !== '' ? json_decode($text, true) : null;

        if ($status >= 400) {
            $err = is_array($data) ? ($data['error'] ?? []) : [];
            throw new DeclinedException(
                $status,
                $err['message'] ?? "Request failed with status {$status}",
                $err['code'] ?? null,
            );
        }

        return $data;
    }
}

final class Declined
{
    public readonly EventsResource $events;
    public readonly CustomersResource $customers;
    public readonly RecoveriesResource $recoveries;
    public readonly SequencesResource $sequences;
    public readonly WebhooksResource $webhooks;
    public readonly IncentivesResource $incentives;
    public readonly AnalyticsResource $analytics;

    public function __construct(string $apiKey, array $options = [])
    {
        if ($apiKey === '') {
            throw new \InvalidArgumentException('API key is required');
        }

        $baseUrl = $options['base_url'] ?? ApiPaths::DEFAULT_BASE_URL;
        $http = $options['http'] ?? new GuzzleClient();
        $transport = new HttpTransport($apiKey, $baseUrl, $http);

        $this->events = new EventsResource($transport);
        $this->customers = new CustomersResource($transport);
        $this->recoveries = new RecoveriesResource($transport);
        $this->sequences = new SequencesResource($transport);
        $this->webhooks = new WebhooksResource($transport);
        $this->incentives = new IncentivesResource($transport);
        $this->analytics = new AnalyticsResource($transport);
    }
}
