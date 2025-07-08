require 'csv'

class MigrateNewsmastAccountsJob < ApplicationJob
  queue_as :default

  def perform(csv_path = Rails.root.join('user_community_export.csv'))
    @missing_accounts = []

    @whitelisted_accounts= [
      "@0fj0@newsmast.social",
      "@09SHEEHANM@newsmast.social",
      "@1000pages@newsmast.social",
      "@2night@newsmast.social",
      "@47photography@newsmast.social",
      "@AFalcon@newsmast.social",
      "@Abrikosoff@newsmast.social",
      "@AlexShvartsman@newsmast.social",
      "@AltonDrew@newsmast.social",
      "@Anders_S@newsmast.social",
      "@Andy@newsmast.social",
      "@AnnaScott@newsmast.social",
      "@Anneliese@newsmast.social",
      "@Aysegul@newsmast.social",
      "@Bassey_Ijomanta@newsmast.social",
      "@Bell@newsmast.social",
      "@BobGatty@newsmast.social",
      "@Blacktiger@newsmast.social",
      "@BlesthThySoul@newsmast.social",
      "@Bubblefarts@newsmast.social",
      "@CBhattacharji@newsmast.social",
      "@Calmsage@newsmast.social",
      "@Cam_Walker@newsmast.social",
      "@Cappuccinogirl@newsmast.social",
      "@Caramel@newsmast.social",
      "@CanWCC@newsmast.social",
      "@ChrisB100@newsmast.social",
      "@Chourouk@newsmast.social",
      "@Clarke617@newsmast.social",
      "@Claudiademelo@newsmast.social",
      "@Crof@newsmast.social",
      "@DadeMurphy@newsmast.social",
      "@DadeMutphy@newsmast.social",
      "@Dailyscandi@newsmast.social",
      "@DarkAlomox@newsmast.social",
      "@Destiny@newsmast.social",
      "@Diva_7057@newsmast.social",
      "@Downes@newsmast.social",
      "@DrCarpineti@newsmast.social",
      "@DrGCrisp@newsmast.social",
      "@DrHannahBB@newsmast.social",
      "@DrKylieSoanes@newsmast.social",
      "@DrMikeWatts@newsmast.social",
      "@Drizzleanddip@newsmast.social",
      "@Ed_Rempel@newsmast.social",
      "@EiEi@newsmast.social",
      "@Eklektikos@newsmast.social",
      "@Empiricism@newsmast.social",
      "@EngineerFinance@newsmast.social",
      "@ErichWeikert@newsmast.social",
      "@Emma_Samson@newsmast.social",
      "@FamilyLawExpert@newsmast.social",
      "@FemalesNFinance@newsmast.social",
      "@FreddieJ@newsmast.social",
      "@FrontSeatPhil@newsmast.social",
      "@Gizmo42@newsmast.social",
      "@GlobalRewilding@newsmast.social",
      "@GraceReckers@newsmast.social",
      "@Greg@newsmast.social",
      "@Grinch@newsmast.social",
      "@Gymbag4u@newsmast.social",
      "@HC_History@newsmast.social",
      "@HariTulsidas@newsmast.social",
      "@Hayleyk1970@newsmast.social",
      "@Hwys2Railways@newsmast.social",
      "@Iyad_Abumoghli@newsmast.social",
      "@JURISTnews@newsmast.social",
      "@JenniferLLawson@newsmast.social",
      "@JessJ@newsmast.social",
      "@JimsPhotos@newsmast.social",
      "@Johan@newsmast.social",
      "@John90@newsmast.social",
      "@JohnJVaccaro@newsmast.social",
      "@JohnnieJae@newsmast.social",
      "@Johnvink@newsmast.social",
      "@JoeyJ0J0@newsmast.social",
      "@JulieAtkinson@newsmast.social",
      "@Jarhead2029@newsmast.social",
      "@KieranRose@newsmast.social",
      "@Kielingdegruen@newsmast.social",
      "@KittyInTheMitty@newsmast.social",
      "@Khomezturro@newsmast.social",
      "@Kschroeder@newsmast.social",
      "@Kyaw@newsmast.social",
      "@KyawZinLinn123@newsmast.social",
      "@Kyn@newsmast.social",
      "@KevinWagar@newsmast.social",
      "@LeanneKeddie@newsmast.social",
      "@LeslieTay@newsmast.social",
      "@Lessig@newsmast.social",
      "@Levicoisch@newsmast.social",
      "@LiveMessy2024@newsmast.social",
      "@Loretta@newsmast.social",
      "@Loukas@newsmast.social",
      "@Laurairby@newsmast.social",
      "@LynnNanos@newsmast.social",
      "@MKandHerBC@newsmast.social",
      "@MichaelCaines@newsmast.social",
      "@MicheleA@newsmast.social",
      "@Migis4991@newsmast.social",
      "@MilitaryAfrica@newsmast.social",
      "@Mie_astrup@newsmast.social",
      "@Miaa@newsmast.social",
      "@MotorcycleGuy@newsmast.social",
      "@MummyMatters@newsmast.social",
      "@Nancie@newsmast.social",
      "@Natsurath@newsmast.social",
      "@Nicolas@newsmast.social",
      "@NurseTed@newsmast.social",
      "@OFMagazine@newsmast.social",
      "@OhnMyint@newsmast.social",
      "@OmarSakr@newsmast.social",
      "@OpalTiger@newsmast.social",
      "@OpsMatters@newsmast.social",
      "@Origami@newsmast.social",
      "@Pavel@newsmast.social",
      "@PetRock@newsmast.social",
      "@Petinder@newsmast.social",
      "@Pghlesbian@newsmast.social",
      "@PhilPlait@newsmast.social",
      "@PlantInitiative@newsmast.social",
      "@PolGeoNow@newsmast.social",
      "@Polotman@newsmast.social",
      "@PriyankaJoshi@newsmast.social",
      "@Pyae000@newsmast.social",
      "@QasimRashid@newsmast.social",
      "@RafiqulMontu@newsmast.social",
      "@RachelBranson@newsmast.social",
      "@Randee@newsmast.social",
      "@Reuben@newsmast.social",
      "@RewildScotland@newsmast.social",
      "@RhondaAlbom@newsmast.social",
      "@Riccardo@newsmast.social",
      "@Roamancing@newsmast.social",
      "@RonCharles@newsmast.social",
      "@RossA@newsmast.social",
      "@Rossoneroblog@newsmast.social",
      "@SJC@newsmast.social",
      "@SWCWomen@newsmast.social",
      "@Sahqon@newsmast.social",
      "@Salexkenyon@newsmast.social",
      "@Sam@newsmast.social",
      "@Sas99@newsmast.social",
      "@Sascha_Feldmann@newsmast.social",
      "@Serious_Feather@newsmast.social",
      "@ShaggyShepherd@newsmast.social",
      "@ShuaE@newsmast.social",
      "@SilverRainbow@newsmast.social",
      "@SithuBo@newsmast.social",
      "@Startupradio@newsmast.social",
      "@StephanHacker2@newsmast.social",
      "@StephenScouted@newsmast.social",
      "@Stregabor@newsmast.social",
      "@SummerS@newsmast.social",
      "@SuperScienceGrl@newsmast.social",
      "@Superpolitics@newsmast.social",
      "@SustMeme@newsmast.social",
      "@TasmanianTimes@newsmast.social",
      "@TestTest@newsmast.social",
      "@TheCultofCalcio@newsmast.social",
      "@TheEnglishLion@newsmast.social",
      "@TheQueerBookish@newsmast.social",
      "@ThirdTime@newsmast.social",
      "@ThomasFoster@newsmast.social",
      "@Tms12@newsmast.social",
      "@Toex@newsmast.social",
      "@ToposInstitute@newsmast.social",
      "@Tricolor7788@newsmast.social",
      "@TuesdayReviewAU@newsmast.social",
      "@Tyom@newsmast.social",
      "@VaniaG@newsmast.social",
      "@WestWeather@newsmast.social",
      "@WestWifey@newsmast.social",
      "@WhiteMode@newsmast.social",
      "@WildCard@newsmast.social",
      "@Willow@newsmast.social",
      "@WilmotsWay@newsmast.social",
      "@YNA@newsmast.social",
      "@Ypsilenna@newsmast.social",
      "@Yunandar@newsmast.social",
      "@Zahid11@newsmast.social",
      "@_shannoncochran@newsmast.social",
      "@alanwelch@newsmast.social",
      "@alawriedejesus@newsmast.social",
      "@alemida44@newsmast.social",
      "@aliciahaydenart@newsmast.social",
      "@allaroundoz@newsmast.social",
      "@alzatari@newsmast.social",
      "@anaslm10@newsmast.social",
      "@arg02@newsmast.social",
      "@arizpe@newsmast.social",
      "@arlettecontrers@newsmast.social",
      "@artbol@newsmast.social",
      "@asausagehastwo@newsmast.social",
      "@askchefdennis@newsmast.social",
      "@atom@newsmast.social",
      "@aung@newsmast.social",
      "@aungmyatmoe@newsmast.social",
      "@ausgeo@newsmast.social",
      "@aydnkocek@newsmast.social",
      "@azizbnchikh@newsmast.social",
      "@babygirl@newsmast.social",
      "@ballhaus@newsmast.social",
      "@bartfaitamas@newsmast.social",
      "@bbdjgfhjhhg@newsmast.social",
      "@beck@newsmast.social",
      "@benogeh@newsmast.social",
      "@berot3@newsmast.social",
      "@bismillah345@newsmast.social",
      "@boroguide@newsmast.social",
      "@brasmus@newsmast.social",
      "@brettmirl@newsmast.social",
      "@bridgeteam@newsmast.social",
      "@bryantout@newsmast.social",
      "@burnitdownpls@newsmast.social",
      "@business@newsmast.social",
      "@buyingseafood@newsmast.social",
      "@candice_chirwa@newsmast.social",
      "@captnmnemo@newsmast.social",
      "@catcafesandiego@newsmast.social",
      "@cate@newsmast.social",
      "@catherinerhyde@newsmast.social",
      "@cbattlegear@newsmast.social",
      "@ccgh@newsmast.social",
      "@chafafa@newsmast.social",
      "@channyeintun@newsmast.social",
      "@chatter@newsmast.social",
      "@chidreams@newsmast.social",
      "@chino@newsmast.social",
      "@chloe_661@newsmast.social",
      "@chloeariellle@newsmast.social",
      "@christina88@newsmast.social",
      "@chrysalismama@newsmast.social",
      "@clairejuliaart@newsmast.social",
      "@claudianatasha_@newsmast.social",
      "@clonnee@newsmast.social",
      "@collected_cards@newsmast.social",
      "@contessalouise@newsmast.social",
      "@crazyjane125@newsmast.social",
      "@csu@newsmast.social",
      "@dadonthemoveph@newsmast.social",
      "@dannyweller@newsmast.social",
      "@darkjamal@newsmast.social",
      "@dave42w@newsmast.social",
      "@deadsuperhero@newsmast.social",
      "@debgod@newsmast.social",
      "@denn@newsmast.social",
      "@dennisfparker@newsmast.social",
      "@deniseoberry@newsmast.social",
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