// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract NovaFi {

```
uint256 public liquidity;

function addLiquidity() public {
    liquidity += 100;
}

function removeLiquidity() public {
    require(liquidity >= 100);

    liquidity -= 100;
}

function getLiquidity() public view returns (uint256){
    return liquidity;
}
```

}
