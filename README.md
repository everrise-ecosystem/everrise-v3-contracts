# EverRise Token and Onchain NFT contracts

## $RISE: The Original Buyback Token Powering The EverRise Ecosystem

[EverRise token (RISE)](https://everrise.com/rise/) is a multi-chain collateralized cryptocurrency that serves as a utility token for cross-chain transfers and secures both the ecosystem and holders with its innovative buyback and staking protocol.

![Ecosystem](https://data.everrise.com/images/ecosystem-800.png)

Stake your RISE holdings to earn a share of the tokens purchased through the automated buyback (liquidity reserve) protocol. You can stake anywhere between 1 and 12 months as well as longer periods as 24 and 36 months, and earn rewards proportional to the amount of tokens staked, weighted by the length of time you have staked your tokens.

## EverRise v3 flattened contracts

[Chainsulting audit](https://github.com/chainsulting/Smart-Contract-Security-Audits/blob/master/EverRise/02_Smart_Contract_Audit_EverRise_Token_Staking_v3.pdf)

### EverRise token Contract 

* [EverRise_flat.sol](blob/main/EverRise_flat.sol) : EverRise token contract
* EverRiseAvax_flat.sol : EverRise token contract (Changes for TraderJoe dex)

# EverRise NFT Stakes

https://user-images.githubusercontent.com/87881922/167014915-d253e3eb-cc7f-435d-adab-e300e07c1590.mp4

## Flexible Staking with On-Chain NFTs

### nftEverRise Staking NFTs, veRISE, claimRise Contract

* nftEverRise_flat.sol : Stake NFTs, vote-escrowed RISE, and rewards RISE
* EverRiseRendererGlyph_flat.sol: OnChain SVG animal glyphs
* EverRiseRenderer_flat.sol: OnChain JSON attribute and SVG renderer 

[EverRise’s innovative staking protocol](https://everrise.com/everstake/) provides stakers with on-chain NFTs that securely store staking contracts directly within your DeFi wallet.

![NFT Stakes](https://data.everrise.com/images/everrise-nft-stakes-800.png)

[EverRise’s innovative staking protocol](https://everrise.com/everstake/) provides stakers with on-chain NFTs that securely store staking contracts directly within your DeFi wallet.

Extensive text and video [EverRise NFT Staking Lab Guide & Walk Through](https://everrise.com/post/everrise-nft-staking-lab-guide/) is available.

With use of on-chain NFTs, staking contracts are now fully secured on the blockchain. Most NFTs today are stored off-chain on a centralized server, with just a serial number and redirect link on the blockchain. These on-server NFTs can be changed in the future by the contract deployer. EverRise makes full use of the public ledger and the immutability of smart contracts by securing all information needed to generate NFT Stakes via [The EverRise NFT Staking Lab](https://v3app.everrise.com/).


![Anatomy](https://data.everrise.com/images/anatomy-everrise-nft-stakes-800.png)


Both the metadata and the image of the EverRise NFT Stakes are stored directly on the blockchain and require no external data source besides the blockchain itself. The attributes and image of the NFT are generated from the exact data of each individual stake.


![veRISE](https://data.everrise.com/images/verise-breakdown-800.png)


The NFT Stake is the container of the RISE token and the veRISE governance tokens. If the NFT is transferred, the tokens move with it. When the NFT is bridged from one blockchain to another, all of its metadata and contained tokens move to the other chain, becoming an NFT Stake of the new chain.


### Supporting contracts

EverRiseStats_flat.sol : [Live stats and pricing](https://data.everrise.com/stats.html) using Chainlink; also historic stats via archive nodes for the ecosystem

