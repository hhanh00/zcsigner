# zcsigner

Zcash watch only wallet and offline signer.

## Use case

Keep the watch only wallet on your phone. You
can receive coins and monitor your wallet balance.

Make secure transactions: Start a transaction from
your watch-only wallet, sign it on your air
gapped phone (in airplane mode), publish it on
your first phone. All data transfers are through
QR codes and cameras.

Demo: https://www.youtube.com/watch?v=gi99-NRUv1o

## Requirements

- Install flutter 2+,
- Requirements android SDK, NDK
- xcode for iOS (not tested)
- Download `sapling-output.params` and `sapling-send.params`
  or copy them from `.zcash-params`, into `assets/`

## Build/Run development

- `cargo make`
- `flutter run`

## Build release / install

Follow the instructions https://flutter.dev/docs/deployment/android

- `cargo make --profile release`
- `flutter build apk` or `flutter build appbundle`
- `flutter install`

# Testnet/Mainnet

Currently builds for mainnet. To use testnet instead,
edit `native/zc_api_ffi/Cargo.toml` and remove
`features: ["mainnet"]`

On mainnet, **USE AT YOUR OWN RISK**. I'm not responsible
for any potential loss of money.
