# frozen_string_literal: true

require "test_helper"

class TestShipyrd < Minitest::Test
  describe "#trigger" do
    after do
      Shipyrd::ENV_VARS.each do |var|
        ENV.delete(var)
      end
    end

    describe "configuration" do
      it "when host isn't configured" do
        ENV["SHIPYRD_HOST"] = nil

        assert_output "Shipyrd: deploy trigger failed with error => ENV['SHIPYRD_HOST'] is not configured\n" do
          Shipyrd.trigger("deploy")
        end
      end

      it "when API key isn't configured" do
        ENV["SHIPYRD_API_KEY"] = nil
        ENV["SHIPYRD_HOST"] = "https://localhost"

        assert_output "Shipyrd: deploy trigger failed with error => ENV['SHIPYRD_API_KEY'] is not configured\n" do
          Shipyrd.trigger("deploy")
        end
      end
    end

    describe "triggering" do
      it "fails gracefully from failed network request" do
        ENV["SHIPYRD_HOST"] = "https://localhost"
        ENV["SHIPYRD_API_KEY"] = "secret"
        ENV["KAMAL_SERVICE_VERSION"] = "example@4152f8"

        stub_request(
          :post,
          "#{Shipyrd.host}/deploys.json"
        ).to_return(
          status: [500, "Application Error"]
        )

        assert_output "Shipyrd: deploy trigger failed with 500(Application Error)\n" do
          Shipyrd.trigger("deploy")
        end
      end

      it "successfully records a deploy in shipyrd" do
        ENV["SHIPYRD_HOST"] = "https://localhost"
        ENV["SHIPYRD_API_KEY"] = "secret"
        ENV["KAMAL_RECORDED_AT"] = Time.now.to_s
        ENV["KAMAL_PERFORMER"] = "n"
        ENV["KAMAL_VERSION"] = "4152f876f56384f268fbdaa7a30dd2e5f5ee3894"
        ENV["KAMAL_SERVICE_VERSION"] = "example@4152f8"
        ENV["KAMAL_HOSTS"] = "867.530.9"
        ENV["KAMAL_COMMAND"] = "deploy"
        ENV["KAMAL_SUBCOMMAND"] = "thingz"
        ENV["KAMAL_ROLE"] = "web"
        ENV["KAMAL_DESTINATION"] = "production"
        ENV["KAMAL_RUNTIME"] = "125"

        event = "deploy-event"
        env = Shipyrd.env

        stub_request(
          :post,
          "#{Shipyrd.host}/deploys.json"
        ).with(
          body: {
            deploy: {
              status: event,
              recorded_at: env["KAMAL_RECORDED_AT"],
              performer: env["KAMAL_PERFORMER"],
              version: env["KAMAL_VERSION"],
              service_version: env["KAMAL_SERVICE_VERSION"],
              hosts: env["KAMAL_HOSTS"],
              command: env["KAMAL_COMMAND"],
              subcommand: env["KAMAL_SUBCOMMAND"],
              role: env["KAMAL_ROLE"],
              destination: env["KAMAL_DESTINATION"],
              runtime: env["KAMAL_RUNTIME"]
            }
          }.to_json,
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer #{Shipyrd.api_key}"
          }
        )

        assert_output "Shipyrd: deploy-event triggered successfully for example@4152f8\n" do
          Shipyrd.trigger(event)
        end
      end
    end
  end
end
