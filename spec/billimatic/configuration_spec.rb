require "spec_helper"

describe Billimatic::Configuration do

  it "uses the production Billimatic URL by default" do
    expect(subject.url).to eq "https://app.billimatic.com.br/api/v1"
  end

  it "uses a default user agent" do
    expect(subject.user_agent).to eq "Billimatic Ruby Client v#{Billimatic::VERSION}"
  end

  it "uses the production Bilimatic host by default" do
    expect(subject.host).to eq "https://app.billimatic.com.br"
  end

end
