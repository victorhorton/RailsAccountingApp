require 'json'

accounts_text = File.read(Rails.root.join('lib', 'seeds', 'accounts.json'))
accounts = JSON.parse(accounts_text)

accounts.each do |account|
  Account.create(
    id: account['id'],
    name: account['name'],
    account_type: account['account_type'],
  )
end

contacts_text = File.read(Rails.root.join('lib', 'seeds', 'contacts.json'))
contacts = JSON.parse(contacts_text)

contacts.each do |contact|
  Contact.create(
    name: contact['name'],
    phone_number: contact['phone_number'],
    email: contact['email'],
    address: contact['address'],
    city: contact['city'],
    state: contact['state'],
    zip: contact['zip'],
    description: contact['description'],
  )
end
