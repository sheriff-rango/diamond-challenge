// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import 'hardhat/console.sol';

contract TokenAvgPrice {

  struct TokenPriceItem {
    uint tokenPrice;
    string previousDate;
  }

  struct TokenPriceStorage {
    string lastDate;
    mapping(string => TokenPriceItem) tokenPrice;
  }
  function tokenPrice() internal pure returns(TokenPriceStorage storage tp) {
    bytes32 postition = keccak256("diamond.standard.diamond.storage");
    assembly {tp.slot := postition}
  }

  function setTokenPrice(string memory selector, uint tokenPriceData) external {
    TokenPriceStorage storage tp = tokenPrice();

    TokenPriceItem memory savedPriceItem = tp.tokenPrice[selector];
    console.log('savedPriceItem', savedPriceItem.tokenPrice);
    if (savedPriceItem.tokenPrice == 0) {
      TokenPriceItem memory newPrice = TokenPriceItem(tokenPriceData, tp.lastDate);
      tp.tokenPrice[selector] = newPrice;
      tp.lastDate = selector;
    } else {
      savedPriceItem.tokenPrice = tokenPriceData;
      tp.tokenPrice[selector] = savedPriceItem;
    }
    //... more code;
  }
  function returnTokenPrice(string memory selector) external view returns(TokenPriceItem memory) {
    TokenPriceStorage storage tp = tokenPrice();
    TokenPriceItem memory data = tp.tokenPrice[selector];
    //... more code
    return data;
  }
  function returnTokenPricePeriod(string memory startDate, string memory endDate) external view returns(uint) {
    TokenPriceStorage storage tp = tokenPrice();
    if (keccak256(abi.encodePacked(startDate)) == keccak256(abi.encodePacked(endDate))) {
      TokenPriceItem memory data = tp.tokenPrice[startDate];
      return data.tokenPrice;
    } else {
      string memory previousDate = endDate;
      uint count = 0;
      uint sum = 0;
      while (keccak256(bytes(startDate)) != keccak256(bytes(previousDate))) {
        TokenPriceItem memory previousTokenPriceItem = tp.tokenPrice[previousDate];
        sum += previousTokenPriceItem.tokenPrice;
        count += 1;
        previousDate = previousTokenPriceItem.previousDate;
      }
      TokenPriceItem memory lastTokenPriceItem = tp.tokenPrice[previousDate];
      sum += lastTokenPriceItem.tokenPrice;
      count += 1;
      return sum / count;
    }
  }
  function returnLastDate() external view returns(string memory) {
    TokenPriceStorage storage tp = tokenPrice();
    string memory data = tp.lastDate;
    return data;
  }

  function supportsInterface(bytes4 _interfaceID) external view returns (bool) {}
}