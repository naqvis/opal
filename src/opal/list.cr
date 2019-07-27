module Opal
  class CLI < Cli::Supercommand
    command "ls"

    class LS < Cli::Command
      command_name "ls"

      class Options
        arg "image", desc: "Repo for which to get tags for", required: true
        help
      end

      class Help
        header "List the tags in a repo"
        caption "List the tags in a repo"
      end

      def run
        repo = Name::Repository.new args.image
        tags = V1::Remote.list repo, V1::Remote.with_auth_from_keychain(Authn::DefaultKeychain.new)
        tags.sort.each { |t| puts t }
      rescue ex
        Logger.error "Error occurred: \n#{ex.message}"
        exit! code: 2
      end
    end
  end
end
