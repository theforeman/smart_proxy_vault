FactoryGirl.define do
  factory :rsa, class: OpenSSL::PKey::RSA do
    skip_create

    transient do
      file nil
    end

    initialize_with { new(File.read(file)) }
  end
end
