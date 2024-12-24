# Ensure the existence of records required to run the application in every environment (production, development, test).
# This script is idempotent, meaning it can be run multiple times without creating duplicate records.

# Create a default user
User.find_or_create_by!(email: "emmiemenz@gmail.com") do |user|
    user.password = "chemistry101"
    user.role = "client"
  end

  # Seed product
    products = [
  {
    provider: "nordVpn",
    provision: "Standard Software Subscription",
    min_value: 5.0,
    max_value: 50000.0,
    currency: "NGN",
    rate: 4.7,
    image: "/images/gift-cards/nordvpn-international.webp",
    description: "Buy NordVPN gift cards with crypto online. Pay on NordVPN with Bitcoin, Ethereum, USDT, USDC, Binance Pay, and other cryptocurrencies. Instant email delivery.",
    info: "This is for the NordVPN Standard Software Subscription For 6 Devices",
    category: "gift card"
  },
  {
    provider: "spar",
    provision: "Gift Card",
    min_value: 5.0,
    max_value: 50000.0,
    currency: "NGN",
    rate: 4.7,
    image: "/images/gift-cards/spar-market-nigeria.webp",
    description: "Buy Spar gift cards with crypto online. Pay on Spar with Bitcoin, Ethereum, USDT, USDC, Binance Pay, and other cryptocurrencies. Instant email delivery.",
    info: "This gift code may only work in Nigeria",
    category: "gift card"
  },
  {
    provider: "playstation",
    provision: "Digital Gaming Services",
    min_value: 10.0,
    max_value: 250.0,
    currency: "USD",
    rate: 4.7,
    image: "/images/gift-cards/sony-playstation-usa.webp",
    description: "Access PlayStation Network using Cryptocurrency. The PlayStation Store is your gateway to a vast array of PlayStation games, PlayStation Plus, in-game currencies, movies, and more. This can be conveniently paid for using popular cryptocurrencies like Bitcoin, Binance Pay, USDT, Ethereum, Dash, Dogecoin, and Litecoin.",
    info: "",
    attention: "Only valid for accounts with USA as selected region. Region is selected during Playstation account creation.",
    category: "gift card"
  },
  {
    provider: "steam",
    provision: "Digital Gaming Services",
    min_value: 5.0,
    max_value: 100.0,
    currency: "USD",
    rate: 4.7,
    image: "/images/gift-cards/steam-usa.webp",
    description: "Buy Steam gift cards with Bitcoin, USDT, USDC, ETH, Dogecoin, Litecoin or Binance Pay. Without creating an account! Steam has become the best place to play and purchase games online, across multiple platforms.",
    attention: "Attention! This product is only valid for accounts with USD selected as the account currency.",
    category: "gift card"
  },
  {
    provider: "xbox",
    provision: "Gaming Gift Card",
    min_value: 5.0,
    max_value: 50000.0,
    currency: "USD",
    rate: 4.7,
    image: "/images/gift-cards/xbox-live-usa.webp",
    description: "Pay for Xbox with Crypto. Buy Xbox Gift Card with Bitcoin, Lightning, Ethereum, Binance Pay, Tether (USDT), USD Coin (USDC), Dogecoin, Litecoin or Dash. Bitrefill's Xbox gift card lets you purchase what ever you want on the Microsoft Store.",
    info: "This gift card is only redeemable on the e-commerce platform",
    attention: "Attention! This product is only valid for accounts with the USA selected as the account region. The currency/region for an Xbox account is set during the account creation and cannot be modified afterward.",
    category: "gift card"
  },
  {
    provider: "skype",
    provision: "Communication Services",
    min_value: 5.0,
    max_value: 50000.0,
    currency: "NGN",
    rate: 4.7,
    image: "/images/gift-cards/skype-usd-international.webp",
    description: "Looking to purchase Skype credit or a virtual number? Bitrefill's Skype gift card lets you pay for all of Skype's great services with Bitcoin, Ethereum, Dash, Dogecoin, and Litecoin.",
    category: "gift card"
  },
  {
    provider: "bankless",
    provision: "Crypto-based Membership",
    min_value: 1.0,
    max_value: 1.0,
    currency: "USD",
    rate: 4.7,
    image: "/images/gift-cards/nordvpn-international.webp",
    description: "Purchase your one year Bankless Citizenship with crypto. Buy a Bankless Citizenship gift card with Bitcoin, Lightning, Ethereum, Binance Pay, USDT, USDC, Dogecoin, Litecoin, Dash. Instant email delivery. No account required. Start living on crypto!",
    info: "This gift card is only redeemable on the e-commerce platform",
    attention: "When redeeming this gift card at Bankless, you will need to share details of a fully functioning debit or credit card. Even though it will not be charged, these details are required.",
    category: "gift card"
  },
  {
    provider: "cherry credit",
    provision: "Gaming Gift Card",
    min_value: 54.0,
    max_value: 80.0,
    currency: "USD",
    rate: 4.7,
    image: "/images/gift-cards/cherry-credits-international.webp",
    description: "Unlock limitless gaming potential with your Bitcoin, ETH or Tether through Cherry Credits Gift Card! Cherry Credits (CC) is a virtual currency that enables you to buy and enjoy over 1,000 games and digital content for popular games such as Black Desert, Dragon Nest, and Travian: Legends.",
    info: "This gift card is redeemable on the e-commerce platform & at the physical store",
    category: "gift card"
  },
  {
    provider: "Kinguin Games Store EUR",
    provision: "Digital Game Services",
    min_value: 54.0,
    max_value: 80.0,
    currency: "USD",
    rate: 4.7,
    image: "/images/gift-cards/kinguin-gift-card-international.webp",
    description: "Kinguin Games Store offers a vast selection of over 95,000 games, DLCs, software, and unique skins for gamers worldwide.",
    info: "This gift card is redeemable on the e-commerce platform & at the physical store",
    category: "gift card"
  },
  {
    provider: "Suregift Multibrand",
    provision: "Multibrand Services",
    min_value: 500.0,
    max_value: 500.0,
    currency: "NGN",
    rate: 4.7,
    image: "/images/gift-cards/suregifts-generic-nigeria.webp",
    category: "gift card"
  },
  {
    provider: "mtn",
    provision: "Mobile Airtime",
    min_value: 5.0,
    max_value: 50000.0,
    currency: "NGN",
    rate: 4.7,
    description: "MTN provides reliable telecommunication services across Nigeria. Recharge airtime to stay connected effortlessly.",
    info: "Use this to recharge any MTN line within Nigeria.",
    category: "mobile provider"
  },
  {
    provider: "mtn",
    provision: "Bundle Data",
    min_value: 500.0,
    max_value: 50000.0,
    currency: "NGN",
    rate: 4.7,
    description: "MTN provides reliable telecommunication services across Nigeria. Recharge airtime to stay connected effortlessly.",
    info: "Use this to recharge any MTN line within Nigeria.",
    category: "mobile provider"
  },
  {
    provider: "ntel",
    provision: "Airtime",
    min_value: 5.0,
    max_value: 50000.0,
    currency: "NGN",
    rate: 4.7,
    description: "ntel offers advanced 4G/LTE services and crystal-clear voice calls. Stay connected with ntel airtime.",
    info: "Recharge ntel for uninterrupted communication and browsing.",
    category: "mobile provider"
  },
  {
    provider: "9-mobile",
    provision: "Airtime",
    min_value: 5.0,
    max_value: 50000.0,
    currency: "NGN",
    rate: 4.7,
    description: "9mobile provides flexible data and voice plans for its subscribers. Easily recharge your line today.",
    info: "Suitable for recharging any 9mobile line in Nigeria.",
    category: "mobile provider"
  },
  {
    provider: "glo",
    provision: "Airtime",
    min_value: 5.0,
    max_value: 50000.0,
    currency: "NGN",
    rate: 4.7,
    description: "Globacom (Glo) offers affordable data and call services across Nigeria. Recharge your line seamlessly.",
    info: "Recharge any Glo line and enjoy unmatched bonuses.",
    category: "mobile provider"
  },
  {
    provider: "airtel",
    provision: "Airtime",
    min_value: 5.0,
    max_value: 50000.0,
    currency: "NGN",
    rate: 4.7,
    description: "Airtel provides quality network coverage and affordable services across Nigeria. Top up your airtime now.",
    info: "Recharge Airtel lines for smooth communication.",
    category: "mobile provider"
  },
  {
    provider: "Vortech Engineering",
    provision: "Solar installation",
    min_value: 5000,
    max_value: 50000,
    image: "/images/services/installing-solar-panels.webp",
    rate: 4.7,
    category: "service",
    currency: "NGN",

  },
  {
    provider: "HPVC Consulatancy",
    provision: "Design and Development of Apartments",
    min_value: 5000,
    max_value: 50000,
    rate: 4.7,
    image: "/images/services/engineering-consultancy.png",
    category: "service",
    currency: "NGN",

  }
]


  products.each do |product_data|
    Product.find_or_create_by!(provider: product_data[:provider]) do |product|
      product.assign_attributes(product_data)
    end
  end
