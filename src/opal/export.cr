module Opal
  class CLI < Cli::Supercommand
    command "export"

    class Export < Cli::Command
      command_name "export"

      class Options
        arg "image", desc: "Image to export", required: true
        arg "output", desc: "Output location", required: true, default: "-"
        help
      end

      class Help
        header <<-EOS
         `Opal export` Export contents of a remote image as a tarball to selected destination
         You can specify file as an export destination.
          
         Default export destination is STDOUT

         Usage:
         Opal export [IMAGE] [DESTINATION]
         EOS
        caption "Export contents of a remote image as a tarball"
        footer <<-EOS
          Example:
          # Write tarball to stdout
          Opal export ubuntu -

          # Write tarball to file
          Opal export ubuntu ubuntu.tar
        EOS
      end

      def run
        src_ref = Name::Reference.parse_reference args.image
        img = V1::Remote.image src_ref, V1::Remote.with_auth_from_keychain(Authn::DefaultKeychain.new)
        fs = V1::Mutate.extract(img)
        begin
          output = open_file(args.output)
          IO.copy fs, output
        ensure
          output.try &.close
        end
      rescue ex
        Logger.error "Error occurred: \n#{ex.message}"
        exit! code: 2
      end

      private def open_file(f)
        return STDOUT if f == "-"
        File.new(f, "w")
      end
    end
  end
end
