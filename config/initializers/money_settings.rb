# frozen_string_literal: true

# clears a deprecation warning
Money.rounding_mode = BigDecimal::ROUND_HALF_UP
