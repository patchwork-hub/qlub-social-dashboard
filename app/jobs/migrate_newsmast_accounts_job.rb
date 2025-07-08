require 'csv'

class MigrateNewsmastAccountsJob < ApplicationJob
  queue_as :default

  def perform(csv_path = Rails.root.join('user_community_export.csv'))
    @missing_accounts = []

    @whitelisted_accounts= [
      "@devenperez@newsmast.social",
      "@diamondlewis@newsmast.social",
      "@dianirawan@newsmast.social",
      "@djape11@newsmast.social",
      "@dleifohcs@newsmast.social",
      "@doctorambient@newsmast.social",
      "@docwinters@newsmast.social",
      "@drshaunanderson@newsmast.social",
      "@dylan_thiam@newsmast.social",
      "@egc25@newsmast.social",
      "@elisexavier@newsmast.social",
      "@emenikeng@newsmast.social",
      "@emeraldphysio@newsmast.social",
      "@emuwasabi@newsmast.social",
      "@enriqueanarte@newsmast.social",
      "@erica@newsmast.social",
      "@exakat@newsmast.social",
      "@familyphysio@newsmast.social",
      "@fatemah@newsmast.social",
      "@fediverso@newsmast.social",
      "@feuerkugel@newsmast.social",
      "@fitinfounder@newsmast.social",
      "@foong@newsmast.social",
      "@francisco_blaha@newsmast.social",
      "@frejusdabord@newsmast.social",
      "@fwd7@newsmast.social",
      "@gabrielblau@newsmast.social",
      "@gavinjmaguire@newsmast.social",
      "@ghutchis@newsmast.social",
      "@glecko@newsmast.social",
      "@gnasralla@newsmast.social",
      "@goofy@newsmast.social",
      "@gospelsong@newsmast.social",
      "@group@newsmast.social",
      "@guchengsnakee@newsmast.social",
      "@hardindr@newsmast.social",
      "@harvinhentry@newsmast.social",
      "@healthcare@newsmast.social",
      "@heimoshuiyu@newsmast.social",
      "@hermitary@newsmast.social",
      "@hrbrmstr@newsmast.social",
      "@ianwalker@newsmast.social",
      "@icey_mark@newsmast.social",
      "@ifonlycom@newsmast.social",
      "@ilovefilm@newsmast.social",
      "@indiajade_68@newsmast.social",
      "@infobl@newsmast.social",
      "@instepphysio@newsmast.social",
      "@iop5@newsmast.social",
      "@ipub@newsmast.social",
      "@irlrefuge@newsmast.social",
      "@islandknabo@newsmast.social",
      "@iostest@newsmast.social",
      "@itsmarta101@newsmast.social",
      "@itzme@newsmast.social",
      "@ivan@newsmast.social",
      "@jackiealpers@newsmast.social",
      "@jaclynasiegel@newsmast.social",
      "@jakeanders@newsmast.social",
      "@jamalpp@newsmast.social",
      "@janrif@newsmast.social",
      "@jasonreiduk@newsmast.social",
      "@jcblautomoto@newsmast.social",
      "@jdp23@newsmast.social",
      "@jeffreyguard@newsmast.social",
      "@jenandreacchi@newsmast.social",
      "@jeremygodwin@newsmast.social",
      "@jessicanewmast@newsmast.social",
      "@jessa@newsmast.social",
      "@jetono@newsmast.social",
      "@jimmy@newsmast.social",
      "@jmenka@newsmast.social",
      "@jncomas@newsmast.social",
      "@joanathx@newsmast.social",
      "@john_90@newsmast.social",
      "@johnbreeze@newsmast.social",
      "@johnhawks@newsmast.social",
      "@johnvoorhees@newsmast.social",
      "@jsit@newsmast.social",
      "@jt1p5@newsmast.social",
      "@jtarde23@newsmast.social",
      "@junctionpoint@newsmast.social",
      "@justinw@newsmast.social",
      "@justwatch@newsmast.social",
      "@k_rose@newsmast.social",
      "@kabtohin2020@newsmast.social",
      "@kaerisonic@newsmast.social",
      "@kaerypheur@newsmast.social",
      "@kakerlake@newsmast.social",
      "@kalhan@newsmast.social",
      "@keithramsey@newsmast.social",
      "@kevinbugati@newsmast.social",
      "@kevinflynn@newsmast.social",
      "@khaled57@newsmast.social",
      "@ksetiya@newsmast.social",
      "@kylesinlynn@newsmast.social",
      "@lgbtq@newsmast.social",
      "@lgsmsec@newsmast.social",
      "@luffy@newsmast.social",
      "@luisaropio@newsmast.social",
      "@luked522@newsmast.social",
      "@lydiechen@newsmast.social",
      "@m0bi@newsmast.social",
      "@m2knewsmast@newsmast.social",
      "@m2knmst@newsmast.social",
      "@macelynne919@newsmast.social",
      "@maketheswitchAU@newsmast.social",
      "@marcelo@newsmast.social",
      "@marianaborges@newsmast.social",
      "@markr@newsmast.social",
      "@martin3456@newsmast.social",
      "@matt_cary@newsmast.social",
      "@mattmoehr@newsmast.social",
      "@mattybob@newsmast.social",
      "@mattskal@newsmast.social",
      "@max@newsmast.social",
      "@max_chaudhary@newsmast.social",
      "@mental_health@newsmast.social",
      "@mervemervemerve@newsmast.social",
      "@metilli@newsmast.social",
      "@mgye@newsmast.social",
      "@michael@newsmast.social",
      "@michael_blogger@newsmast.social",
      "@michaelcohen@newsmast.social",
      "@mikea@newsmast.social",
      "@mikesplaces@newsmast.social",
      "@min2k09@newsmast.social",
      "@minkhantBL@newsmast.social",
      "@minkhantkyaw@newsmast.social",
      "@minusgefuel@newsmast.social",
      "@miroslavglavic@newsmast.social",
      "@mkk001@newsmast.social",
      "@mohammadromjan@newsmast.social",
      "@mombian@newsmast.social",
      "@momentumphysio@newsmast.social",
      "@monicareinagel@newsmast.social",
      "@mongabay@newsmast.social",
      "@moragakd@newsmast.social",
      "@msafaksari@newsmast.social",
      "@mttaggart@newsmast.social",
      "@multimodal@newsmast.social",
      "@muzaffarab@newsmast.social",
      "@mweinbach@newsmast.social",
      "@nancymangano@newsmast.social",
      "@natbas@newsmast.social",
      "@neirda@newsmast.social",
      "@newsmast@newsmast.social",
      "@nexstepphysio@newsmast.social",
      "@nigelp@newsmast.social",
      "@nincodedo@newsmast.social",
      "@niroran@newsmast.social",
      "@nisemikol@newsmast.social",
      "@noisediver@newsmast.social",
      "@not_so_social@newsmast.social",
      "@notiska@newsmast.social",
      "@nowinaminute@newsmast.social",
      "@nyeinBinarylab@newsmast.social",
      "@nyeinygn@newsmast.social",
      "@n0no123@newsmast.social",
      "@oceanknigge@newsmast.social",
      "@ommo@newsmast.social",
      "@pam_palmater@newsmast.social",
      "@pennywalker@newsmast.social",
      "@peter@newsmast.social",
      "@peterthepainter@newsmast.social",
      "@petri@newsmast.social",
      "@petenothing@newsmast.social",
      "@physioemerald@newsmast.social",
      "@physioedmonton@newsmast.social",
      "@pikarl13@newsmast.social",
      "@pjoter9@newsmast.social",
      "@plus@newsmast.social",
      "@poke@newsmast.social",
      "@pot8um@newsmast.social",
      "@ppttest456@newsmast.social",
      "@prabhakar@newsmast.social",
      "@putuu@newsmast.social",
      "@qurquma@newsmast.social",
      "@r0yaL@newsmast.social",
      "@rach_garr@newsmast.social",
      "@rajudbg@newsmast.social",
      "@ravi101@newsmast.social",
      "@realgnomidad@newsmast.social",
      "@rebarkable@newsmast.social",
      "@reverb@newsmast.social",
      "@rewildingsam@newsmast.social",
      "@ritesh@newsmast.social",
      "@robbhoyy@newsmast.social",
      "@robhoy@newsmast.social",
      "@robpollice@newsmast.social",
      "@roggim@newsmast.social",
      "@rogerg44@newsmast.social",
      "@rogergraf@newsmast.social",
      "@ruslan@newsmast.social",
      "@ryankhan@newsmast.social",
      "@sallyhawkins@newsmast.social",
      "@samf@newsmast.social",
      "@saskia@newsmast.social",
      "@satvika@newsmast.social",
      "@sciencebase@newsmast.social",
      "@sebbz@newsmast.social",
      "@seema@newsmast.social",
      "@seehearpodcast@newsmast.social",
      "@sev@newsmast.social",
      "@shelldoor@newsmast.social",
      "@shoqv4@newsmast.social",
      "@sintrenton@newsmast.social",
      "@sitothebo@newsmast.social",
      "@skk@newsmast.social",
      "@snoopy@newsmast.social",
      "@soccerhub@newsmast.social",
      "@sophia@newsmast.social",
      "@spacealgae@newsmast.social",
      "@sport@newsmast.social",
      "@steve116@newsmast.social",
      "@stevebownan@newsmast.social",
      "@strayegg@newsmast.social",
      "@sttanner@newsmast.social",
      "@sunrisephysio@newsmast.social",
      "@sustainabilityx@newsmast.social",
      "@suthit@newsmast.social",
      "@sylphrenetic@newsmast.social",
      "@tatkotel@newsmast.social",
      "@tderyugina@newsmast.social",
      "@teowawki@newsmast.social",
      "@testmeme@newsmast.social",
      "@testpp34@newsmast.social",
      "@textdump@newsmast.social",
      "@thelmzkitchen@newsmast.social",
      "@thejustinto@newsmast.social",
      "@thepetsnet@newsmast.social",
      "@therfff@newsmast.social",
      "@tillathenun@newsmast.social",
      "@tkruck6@newsmast.social",
      "@tom2022@newsmast.social",
      "@tom_webler@newsmast.social",
      "@tomy@newsmast.social",
      "@travtasy@newsmast.social",
      "@true@newsmast.social",
      "@tuckerm@newsmast.social",
      "@uthi@newsmast.social",
      "@valeriadepaiva@newsmast.social",
      "@vegannutrition@newsmast.social",
      "@vijay@newsmast.social",
      "@vlp00@newsmast.social",
      "@wannely@newsmast.social",
      "@wbbdaily@newsmast.social",
      "@wdshow@newsmast.social",
      "@weblink@newsmast.social",
      "@wfryer@newsmast.social",
      "@wildlife@newsmast.social",
      "@willwinter@newsmast.social",
      "@wjnewman@newsmast.social",
      "@womens_voices@newsmast.social",
      "@wootang71@newsmast.social",
      "@worldbyisa@newsmast.social",
      "@wytham_woods@newsmast.social",
      "@xjxjxjx@newsmast.social",
      "@yanmoenaing@newsmast.social",
      "@yarzar@newsmast.social",
      "@yemyatthu_cs@newsmast.social",
      "@yethiha_codigo@newsmast.social",
      "@yisem@newsmast.social",
      "@zheka296@newsmast.social"
    ]
    
    owner_role = UserRole.find_by(name: 'Owner')
    owner_user = User.find_by(role: owner_role)
    return Rails.logger.error('Owner user not found. Aborting migration.') unless owner_user

    @owner_token = fetch_oauth_token(owner_user.id)
    return Rails.logger.error('Owner access token not found. Aborting migration.') unless @owner_token

    Rails.logger.info "Starting migration of accounts from #{csv_path}"

    CSV.foreach(csv_path, headers: true) do |row|
        process_batch(row)
    end
    
    # Output missing accounts at the end
    output_missing_accounts
  end

  private

  def process_batch(row)
    # Preload communities
    handle = row['handle']
    communities_json = row['communities']

    if @whitelisted_accounts.include?(handle)
      communities_data = JSON.parse(communities_json)

      primary_slug = communities_data['primary']
      other_slugs = communities_data['others'] || []

      # Combine all community slugs
      all_slugs = [primary_slug] + other_slugs

      # Prepare account queries
    
      account_id = search_target_account_id(handle, @owner_token)
      account = Account.find_by(id: account_id)
      existing_communities = Community.where(slug: all_slugs, channel_type: 'newsmast')

      if account
        JoinedCommunity.where(account_id: account.id).destroy_all

        existing_communities.each do |community|

          if primary_slug && (primary_slug == community.slug)
            is_primary = true
          else
            is_primary = false
          end
          JoinedCommunity.create!(
            account_id: account.id,
            patchwork_community_id: community.id,
            is_primary: is_primary
          )
          Rails.logger.info "Created joined_community for account #{handle}."

        end
      else
        @missing_accounts << handle
      end
    end
  end

  def output_missing_accounts
    Rails.logger.info "="*80
    Rails.logger.info "MIGRATION COMPLETED"
    Rails.logger.info "="*80
    
    if @missing_accounts.empty?
      Rails.logger.info "✅ All accounts were found successfully!"
    else
      Rails.logger.info "❌ Missing accounts summary:"
      Rails.logger.info "Total missing accounts: #{@missing_accounts.length}"
      Rails.logger.info "-" * 80
      
      @missing_accounts.each_with_index do |account, index|
        Rails.logger.info "#{account}"
      end      
    end
    
    Rails.logger.info "="*80
  end

  def search_target_account_id(query, owner_token)
    retries = 20
    result = nil
    while retries >= 0
      result = ContributorSearchService.new(
        query,
        url: ENV['MASTODON_INSTANCE_URL'],
        token: owner_token
      ).call
      if result.any?
        return result.last['id']
      end
      retries -= 1
    end
    nil
  end

  def fetch_oauth_token(user_id)
    token_service = GenerateAdminAccessTokenService.new(user_id)
    token_service.call
  end
end