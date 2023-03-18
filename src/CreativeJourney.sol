// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract CreativeJourney is ERC721Enumerable, Ownable {
    uint256 public MAX_SUPPLY; // init to 0
    uint256 public salePrice; // init to 0
    string private _baseTokenURI;
    string private _tokenURISuffix;

    constructor(string memory name, string memory symbol, string memory baseURI, string memory tokenURISuffix)
        ERC721(name, symbol)
    {
        _baseTokenURI = baseURI;
        _tokenURISuffix = tokenURISuffix;
    }

    function increaseMaxSupply(uint256 amount) public onlyOwner {
        MAX_SUPPLY += amount;
    }

    function mint(address to) public onlyOwner {
        uint256 tokenId = totalSupply() + 1;
        if (tokenId > MAX_SUPPLY) {
            MAX_SUPPLY = tokenId;
        }
        _safeMint(to, tokenId);
    }

    function mintPublic() public payable {
        require(totalSupply() < MAX_SUPPLY, "Max supply reached");
        require(msg.value >= salePrice, "Insufficient ether sent");
        uint256 tokenId = totalSupply() + 1;
        _safeMint(msg.sender, tokenId);
    }

    function setSalePrice(uint256 price) public onlyOwner {
        salePrice = price;
    }

    function setBaseURI(string memory baseURI) public onlyOwner {
        _baseTokenURI = baseURI;
    }

    function setTokenURISuffix(string memory tokenURISuffix) public onlyOwner {
        _tokenURISuffix = tokenURISuffix;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "Token does not exist");
        if (bytes(_baseTokenURI).length > 0) {
            string memory tokenString = Strings.toString(tokenId);
            return string(abi.encodePacked(_baseTokenURI, tokenString, _tokenURISuffix));
        } else {
            return "";
        }
    }

    function withdraw() public onlyOwner {
        uint balance = address(this).balance;
        payable(msg.sender).transfer(balance);
    }
}
