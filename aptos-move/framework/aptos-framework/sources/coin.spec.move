spec aptos_framework::coin {

    spec initialize_supply_config {
       let aptos_addr = signer::address_of(aptos_framework);
       aborts_if aptos_addr != @aptos_framework;
       aborts_if exists<SupplyConfig>(aptos_addr);
       ensures !global<SupplyConfig>(aptos_addr).allow_upgrades;
       ensures exists<SupplyConfig>(aptos_addr);
    }

    spec allow_supply_upgrades {
        let aptos_addr = signer::address_of(aptos_framework);
        aborts_if aptos_addr != @aptos_framework;
        aborts_if !exists<SupplyConfig>(aptos_addr);
        ensures global<SupplyConfig>(aptos_addr).allow_upgrades == allowed;
    }

    spec balance {
        aborts_if !exists<CoinStore<CoinType>>(owner);
        ensures result == global<CoinStore<CoinType>>(owner).coin.value;
    }

    /*spec burn {
        let addr = spec_coin_address<CoinType>();
        aborts_if coin.value <= 0;
        aborts_if !exists<CoinInfo<CoinType>>(addr);
    }*/

    spec burn_from {

    }

    spec merge {
        ensures dst_coin.value == old(dst_coin).value + source_coin.value;
    }

    spec deposit {
        aborts_if !exists<CoinStore<CoinType>>(account_addr);
        let coin_store = global<CoinStore<CoinType>>(account_addr);
        aborts_if coin_store.frozen;
        ensures global<CoinStore<CoinType>>(account_addr).coin.value == old(global<CoinStore<CoinType>>(account_addr)).coin.value + coin.value;
    }

    spec destroy_zero {
        aborts_if zero_coin.value != 0;
    }

    spec extract {
        aborts_if coin.value < amount;
        ensures result.value == amount;
        ensures coin.value == old(coin).value - amount;
    }

    spec extract_all {
        ensures result.value == old(coin).value;
        ensures coin.value == 0;
    }

    spec withdraw {
        let account_addr = signer::address_of(account);
        let coin_store = global<CoinStore<CoinType>>(account_addr);
        let post coin_store_post = global<CoinStore<CoinType>>(account_addr);
        aborts_if !exists<CoinStore<CoinType>>(account_addr);
        aborts_if coin_store.frozen;
        aborts_if coin_store.coin.value < amount;
        ensures coin_store_post.coin.value == coin_store.coin.value - amount;
    }


    spec register {
        let account_addr = signer::address_of(account);
        aborts_if exists<CoinStore<CoinType>>(account_addr);
        aborts_if !exists<aptos_framework::account::Account>(account_addr);
        let acc = global<aptos_framework::account::Account>(account_addr);
        aborts_if acc.guid_creation_num + 2 > MAX_U64;
        ensures exists<CoinStore<CoinType>>(account_addr);
    }


    spec transfer {

        let account_addr_from = signer::address_of(from);
        let coin_store_from = global<CoinStore<CoinType>>(account_addr_from);
        let post coin_store_post_from = global<CoinStore<CoinType>>(account_addr_from);
        let coin_store_to = global<CoinStore<CoinType>>(to);
        let post coin_store_post_to = global<CoinStore<CoinType>>(to);

        aborts_if !exists<CoinStore<CoinType>>(account_addr_from);
        aborts_if !exists<CoinStore<CoinType>>(to);
        aborts_if coin_store_from.frozen;
        aborts_if coin_store_to.frozen;
        aborts_if coin_store_from.coin.value < amount;

        ensures account_addr_from != to ==> coin_store_post_from.coin.value ==
                 coin_store_from.coin.value - amount;
        ensures account_addr_from != to ==> coin_store_post_to.coin.value == coin_store_to.coin.value + amount;
        ensures account_addr_from == to ==> coin_store_post_from.coin.value == coin_store_from.coin.value;
    }


    spec freeze_coin_store {
        aborts_if !exists<CoinStore<CoinType>>(account_addr);
        let post coin_store = global<CoinStore<CoinType>>(account_addr);
        ensures coin_store.frozen;
    }

    spec upgrade_supply {
        //aborts_if
    }


    spec mint {
        pragma opaque;
        let addr = spec_coin_address<CoinType>();
        modifies global<CoinInfo<CoinType>>(addr);
        aborts_if [abstract] false;
        ensures [concrete] result.value == amount;
    }

    spec coin_address {
        pragma opaque;
        ensures [abstract] result == spec_coin_address<CoinType>();
    }

    spec fun spec_coin_address<CoinType>(): address {
        // TODO: abstracted due to the lack of support for `type_info` in Prover.
        @0x0
    }

    spec value {
        ensures result == coin.value;
    }

    spec zero {
        ensures result.value == 0;
    }
}
