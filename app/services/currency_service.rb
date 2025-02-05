# require "uri"
# require 'json'

class CurrencyService
    include HTTParty

    base_uri "https://api.coingecko.com/api/v3"

    def initialize( from_curr, to_curr, amount)

        @from_curr = from_curr
        @to_curr = to_curr
        @amount = amount

    end


    def get_conversion


        currency = Currency.first


        begin

            if currency.present?



                if Time.now  - Time.parse(currency["rate_time_stamp"]) > 3.minutes

                    response = self.class.get("/exchange_rates")
                    time = Time.now

                    currency.update(currency_rates: response, rate_time_stamp: time )

                    json_parse = JSON.parse(currency["currency_rates"])

                    from_rate = json_parse["rates"][@from_curr]["value"]
                    to_rate = json_parse["rates"][@to_curr]["value"]


                    conversion = OpenStruct.new(from_rate: from_rate, to_rate: to_rate)

                    return {response: conversion.table}


                end

               json_string = JSON.parse(currency["currency_rates"])

                from_rate = json_string["rates"][@from_curr]["value"]
                to_rate = json_string["rates"][@to_curr]["value"]


                conversion =  OpenStruct.new(from_rate: from_rate, to_rate: to_rate)

                return {response: conversion.table}

            else

                response = self.class.get("/exchange_rates")


                time = Time.now

                currency = Currency.create(currency_rates: response, rate_time_stamp: time)
                json_string = JSON.parse(currency["currency_rates"])


                    from_rate = json_string["rates"][@from_curr]["value"]
                    to_rate = json_string["rates"][@to_curr]["value"]


                    conversion =  OpenStruct.new(from_rate: from_rate, to_rate: to_rate)

                    return {response: conversion.table}

            end

        rescue StandardError => e
            binding.b
            return {message: "#{e.message}", status: "error"}
        end

    end






end