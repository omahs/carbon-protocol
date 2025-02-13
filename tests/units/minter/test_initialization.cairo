// SPDX-License-Identifier: MIT

%lang starknet

// Starkware dependencies
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256
from starkware.cairo.common.bool import TRUE, FALSE

// Local dependencies
from tests.units.minter.library import setup, prepare, CarbonableMinter

@view
func __setup__{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    return setup();
}

@external
func test_initialization{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    alloc_locals;

    // prepare minter instance
    let public_sale_open = FALSE;
    let max_buy_per_tx = 5;
    let unit_price = Uint256(10, 0);
    let max_supply_for_mint = Uint256(10, 0);
    let reserved_supply_for_mint = Uint256(5, 0);
    let (local context) = prepare(
        public_sale_open=public_sale_open,
        max_buy_per_tx=max_buy_per_tx,
        unit_price=unit_price,
        max_supply_for_mint=max_supply_for_mint,
        reserved_supply_for_mint=reserved_supply_for_mint,
    );

    // run scenario
    %{ stop=start_prank(context.signers.anyone) %}
    let (returned_carbonable_project_address) = CarbonableMinter.carbonable_project_address();
    assert returned_carbonable_project_address = context.mocks.carbonable_project_address;

    let (payment_token_address) = CarbonableMinter.payment_token_address();
    assert payment_token_address = context.mocks.payment_token_address;

    let (pre_sale_open) = CarbonableMinter.pre_sale_open();
    let (whitelist_merkle_root) = CarbonableMinter.whitelist_merkle_root();
    assert pre_sale_open = whitelist_merkle_root;

    let (returned_public_sale_open) = CarbonableMinter.public_sale_open();
    assert returned_public_sale_open = public_sale_open;

    let (returned_max_buy_per_tx) = CarbonableMinter.max_buy_per_tx();
    assert returned_max_buy_per_tx = max_buy_per_tx;

    let (returned_unit_price) = CarbonableMinter.unit_price();
    assert returned_unit_price = unit_price;

    let (returned_reserved_supply_for_mint) = CarbonableMinter.reserved_supply_for_mint();
    assert returned_reserved_supply_for_mint = reserved_supply_for_mint;
    %{ stop() %}

    return ();
}

@external
func test_initialization_revert_unit_price_invalid{
    syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
}() {
    alloc_locals;

    // prepare minter instance
    let public_sale_open = FALSE;
    let max_buy_per_tx = 5;
    let unit_price = Uint256(10, -1);
    let max_supply_for_mint = Uint256(10, 0);
    let reserved_supply_for_mint = Uint256(5, 0);

    %{ expect_revert("TRANSACTION_FAILED", "CarbonableMinter: unit_price is not a valid Uint256") %}
    let (local context) = prepare(
        public_sale_open=public_sale_open,
        max_buy_per_tx=max_buy_per_tx,
        unit_price=unit_price,
        max_supply_for_mint=max_supply_for_mint,
        reserved_supply_for_mint=reserved_supply_for_mint,
    );

    return ();
}

@external
func test_initialization_revert_max_supply_for_mint_invalid{
    syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
}() {
    alloc_locals;

    // prepare minter instance
    let public_sale_open = FALSE;
    let max_buy_per_tx = 5;
    let unit_price = Uint256(10, 0);
    let max_supply_for_mint = Uint256(10, -1);
    let reserved_supply_for_mint = Uint256(5, 0);

    %{ expect_revert("TRANSACTION_FAILED", "CarbonableMinter: max_supply_for_mint is not a valid Uint256") %}
    let (local context) = prepare(
        public_sale_open=public_sale_open,
        max_buy_per_tx=max_buy_per_tx,
        unit_price=unit_price,
        max_supply_for_mint=max_supply_for_mint,
        reserved_supply_for_mint=reserved_supply_for_mint,
    );

    return ();
}

@external
func test_initialization_revert_reserved_supply_for_mint_invalid{
    syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
}() {
    alloc_locals;

    // prepare minter instance
    let public_sale_open = FALSE;
    let max_buy_per_tx = 5;
    let unit_price = Uint256(10, 0);
    let max_supply_for_mint = Uint256(10, 0);
    let reserved_supply_for_mint = Uint256(5, -1);

    %{ expect_revert("TRANSACTION_FAILED", "CarbonableMinter: reserved_supply_for_mint is not a valid Uint256") %}
    let (local context) = prepare(
        public_sale_open=public_sale_open,
        max_buy_per_tx=max_buy_per_tx,
        unit_price=unit_price,
        max_supply_for_mint=max_supply_for_mint,
        reserved_supply_for_mint=reserved_supply_for_mint,
    );

    return ();
}
