# encoding: utf-8
require "spec_helper"
require "logstash/patterns/core"

describe "FIREWALLS" do


  let(:pattern104001)    { "CISCOFW104001" }

  context "parsing a 104001 message" do

    let(:value) { "(Secondary) Switching to ACTIVE - Service card in other unit has failed" }

    subject     { grok_match(pattern104001, value) }

    it { should include("switch_reason" => "Service card in other unit has failed") }

    it "generates a message field" do
      expect(subject["message"]).to include("(Secondary) Switching to ACTIVE - Service card in other unit has failed")
    end
  end

  let(:pattern106100)    { "CISCOFW106100" }

  context "parsing a 106100 message" do

    let(:value) { "access-list inside permitted tcp inside/10.10.123.45(51763) -> outside/192.168.67.89(80) hit-cnt 1 first hit [0x62c4905, 0x0]" }

    subject     { grok_match(pattern106100, value) }

    it { should include("policy_id" => "inside") }

    it "generates a message field" do
      expect(subject["message"]).to include("access-list inside permitted tcp inside/10.10.123.45(51763) -> outside/192.168.67.89(80) hit-cnt 1 first hit [0x62c4905, 0x0]")
    end
  end

  let(:pattern106100)    { "CISCOFW106100" }

  context "parsing a 106100 message with hypen in acl name" do

    let(:value) { "access-list outside-entry permitted tcp outside/10.11.12.13(54726) -> inside/192.168.17.18(80) hit-cnt 1 300-second interval [0x32b3835, 0x0]" }

    subject     { grok_match(pattern106100, value) }

    it { should include("policy_id" => "outside-entry") }

    it "generates a message field" do
      expect(subject["message"]).to include("access-list outside-entry permitted tcp outside/10.11.12.13(54726) -> inside/192.168.17.18(80) hit-cnt 1 300-second interval [0x32b3835, 0x0]")
    end
  end

  let(:pattern106023) { "CISCOFW106023" }

  context "parsing a 106023 message" do

    let(:value) { 'Deny tcp src outside:192.168.1.1/50240 dst inside:192.168.1.2/23 by access-group "S_OUTSIDE_TO_INSIDE" [0x54c7fa80, 0x0]' }

    subject { grok_match(pattern106023, value) }

    it 'should break the message up into fields' do
      expect(subject['action']).to eq('Deny')
      expect(subject['src_interface']).to eq('outside')
      expect(subject['dst_interface']).to eq('inside')
      expect(subject['protocol']).to eq('tcp')
      expect(subject['src_ip']).to eq('192.168.1.1')
      expect(subject['dst_ip']).to eq('192.168.1.2')
      expect(subject['policy_id']).to eq('S_OUTSIDE_TO_INSIDE')
    end
  end

  context "parsing a 106023 message with a protocol number" do

    let(:value) { 'Deny protocol 103 src outside:192.168.1.1/50240 dst inside:192.168.1.2/23 by access-group "S_OUTSIDE_TO_INSIDE" [0x54c7fa80, 0x0]' }

    subject { grok_match(pattern106023, value) }

    it 'should break the message up into fields' do
      expect(subject['action']).to eq('Deny')
      expect(subject['src_interface']).to eq('outside')
      expect(subject['dst_interface']).to eq('inside')
      expect(subject['protocol']).to eq('103')
      expect(subject['src_ip']).to eq('192.168.1.1')
      expect(subject['dst_ip']).to eq('192.168.1.2')
      expect(subject['policy_id']).to eq('S_OUTSIDE_TO_INSIDE')
    end
  end

  context "parsing a 106023 message with a hostname" do

    let(:value) { 'Deny tcp src outside:192.168.1.1/50240 dst inside:www.example.com/23 by access-group "S_OUTSIDE_TO_INSIDE" [0x54c7fa80, 0x0]' }

    subject { grok_match(pattern106023, value) }

    it 'should break the message up into fields' do
      expect(subject['action']).to eq('Deny')
      expect(subject['src_interface']).to eq('outside')
      expect(subject['dst_interface']).to eq('inside')
      expect(subject['protocol']).to eq('tcp')
      expect(subject['src_ip']).to eq('192.168.1.1')
      expect(subject['dst_ip']).to eq('www.example.com')
      expect(subject['policy_id']).to eq('S_OUTSIDE_TO_INSIDE')
    end
  end
end
