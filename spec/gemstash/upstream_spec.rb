require "spec_helper"

describe Gemstash::Upstream do
  it "parses an escaped uri" do
    upstream_uri = Gemstash::Upstream.new("https%3A%2F%2Frubygems.org%2F")
    expect(upstream_uri.to_s).to eq("https://rubygems.org/")
    expect(upstream_uri.host).to eq("rubygems.org")
    expect(upstream_uri.scheme).to eq("https")
    expect(upstream_uri.url("gems")).to eq("https://rubygems.org/gems")
    expect(upstream_uri.user).to be_nil
    expect(upstream_uri.password).to be_nil
  end

  it "parses a clear uri" do
    upstream_uri = Gemstash::Upstream.new("https://rubygems.org/")
    expect(upstream_uri.to_s).to eq("https://rubygems.org/")
    expect(upstream_uri.host).to eq("rubygems.org")
    expect(upstream_uri.scheme).to eq("https")
    expect(upstream_uri.url("gems")).to eq("https://rubygems.org/gems")
    expect(upstream_uri.user).to be_nil
    expect(upstream_uri.password).to be_nil
  end

  it "supports url auth in the uri" do
    upstream_uri = Gemstash::Upstream.new("https://myuser:mypassword@rubygems.org/")
    expect(upstream_uri.user).to eq("myuser")
    expect(upstream_uri.password).to eq("mypassword")
  end

  it "distinguishes between ports, auths, and paths" do
    upstream_uri = Gemstash::Upstream.new("https://rubygems.org/")
    auth_upstream_uri = Gemstash::Upstream.new("https://myuser:mypassword@rubygems.org/")
    port_upstream_uri = Gemstash::Upstream.new("https://rubygems.org:4321/")
    path_upstream_uri = Gemstash::Upstream.new("https://rubygems.org/custom/path")
    expect(upstream_uri.host_id).to_not eq(auth_upstream_uri.host_id)
    expect(upstream_uri.host_id).to_not eq(port_upstream_uri.host_id)
    expect(upstream_uri.host_id).to_not eq(path_upstream_uri.host_id)
    expect(auth_upstream_uri.host_id).to_not eq(port_upstream_uri.host_id)
    expect(auth_upstream_uri.host_id).to_not eq(path_upstream_uri.host_id)
    expect(port_upstream_uri.host_id).to_not eq(path_upstream_uri.host_id)
  end

  it "supports building urls with parameters" do
    upstream_uri = Gemstash::Upstream.new("https://rubygems.org/")
    expect(upstream_uri.url("gems", "key=value")).to eq("https://rubygems.org/gems?key=value")
  end

  it "fails if the uri is not valid" do
    expect { Gemstash::Upstream.new("something_that_is_not_an_uri") }.to raise_error(
      /URL 'something_that_is_not_an_uri' is not valid/)
  end
end

describe Gemstash::UpstreamGemName do
  context "With a simple upstream" do
    let(:upstream) { Gemstash::Upstream.new("https://rubygems.org/") }

    it "resolves to the gem name" do
      expect(Gemstash::UpstreamGemName.new(upstream, "mygemname").to_s).to eq("mygemname")
    end

    it "removes the trailing .gem from the name" do
      gem_name = Gemstash::UpstreamGemName.new(upstream, "mygemname-1.0.1.gem")
      expect(gem_name.id).to eq("mygemname-1.0.1.gem")
      expect(gem_name.name).to eq("mygemname-1.0.1")
    end
  end
end
