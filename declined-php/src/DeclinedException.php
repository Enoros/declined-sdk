<?php

declare(strict_types=1);

namespace Declined;

final class DeclinedException extends \RuntimeException
{
    public function __construct(
        public readonly int $status,
        string $message,
        public readonly ?string $code = null,
    ) {
        parent::__construct($message);
    }
}
