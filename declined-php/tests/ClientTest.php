<?php

declare(strict_types=1);

namespace Declined\Tests;

use Declined\ApiPaths;
use Declined\Declined;
use GuzzleHttp\Client;
use GuzzleHttp\Handler\MockHandler;
use GuzzleHttp\HandlerStack;
use GuzzleHttp\Psr7\Response;
use PHPUnit\Framework\TestCase;

final class ClientTest extends TestCase
{
    private const API_KEY = 'decl_live_sk_test_key';

    private function clientWithMock(array $responses): Declined
    {
        $mock = new MockHandler($responses);
        $http = new Client(['handler' => HandlerStack::create($mock)]);
        return new Declined(self::API_KEY, ['http' => $http]);
    }

  /** @dataProvider endpointProvider */
    public function testEndpoint(string $resource, string $method, string $path, string $httpMethod, array $args): void
    {
        $client = $this->clientWithMock([
            new Response(200, ['Content-Type' => 'application/json'], json_encode(['data' => [], 'has_more' => false])),
        ]);

        $client->{$resource}->{$method}(...$args);
    }

    public static function endpointProvider(): array
    {
        return [
            ['events', 'create', ApiPaths::EVENTS, 'POST', [[
                'event_id' => 'evt_1',
                'type' => 'payment_failed',
                'customer_id' => 'cus_1',
            ]]],
            ['customers', 'list', ApiPaths::CUSTOMERS, 'GET', []],
            ['recoveries', 'list', ApiPaths::RECOVERIES, 'GET', []],
            ['sequences', 'list', ApiPaths::SEQUENCES, 'GET', []],
            ['webhooks', 'list', ApiPaths::WEBHOOKS, 'GET', []],
            ['incentives', 'list', ApiPaths::INCENTIVES, 'GET', []],
            ['analytics', 'get', ApiPaths::ANALYTICS, 'GET', []],
            ['events', 'markPaymentRecovered', ApiPaths::EVENTS, 'POST', [[
                'event_id' => 'evt_2',
                'customer_id' => 'cus_1',
                'invoice_id' => 'inv_1',
            ]]],
            ['recoveries', 'markRecovered', ApiPaths::recoveryMarkRecovered('ra_123'), 'POST', ['ra_123']],
        ];
    }
}
