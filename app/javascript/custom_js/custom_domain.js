$(document).ready(function() {
  const CommunitySetup = (function() {
    const $container = $('.container-fluid');
    const $domainSwitch = $('#domain_switch');
    const $subdomainSection = $('#subdomain_section');
    const $customDomainSection = $('#custom_domain_section');
    const $customDomainInput = $('#custom_domain_input');
    const $continueButton = $('#continue_button');
    const $form = $('form');

    let state = {
      isChannelFeed: $container.data('is-channel-feed'),
      currentDomain: '',
      domainVerified: false,
      isSubdomainMode: !$domainSwitch.is(':checked')
    };

    const elements = {
      refreshBtn: $('#refresh_domain_btn'),
      addDomainBtn: $('#add_domain_btn'),
      editDomainBtn: $('#edit_domain_btn'),
      dnsTable: $('#dns_records_table'),
      domainStatus: $('#domain_status'),
      addDomainStatus: $('#add_domain_status')
    };

    function init() {
      if (!state.isChannelFeed) {
        bindEvents();
        handleInitialState();
      }
      updateContinueButton();
    }

    function bindEvents() {
      $domainSwitch.on('change', handleDomainSwitch);
      $subdomainSection.find('input').on('keyup change', updateContinueButton);
      $customDomainInput.on('keyup change', updateContinueButton);
      $form.on('submit', handleFormSubmit);
      elements.refreshBtn.on('click', handleDomainRefresh);
      elements.addDomainBtn.on('click', handleAddDomain);
      elements.editDomainBtn.on('click', handleEditDomain);
    }

    function handleDomainSwitch() {
      const isCustomDomain = $(this).is(':checked');
      state.isSubdomainMode = !isCustomDomain;

      toggleSections(isCustomDomain);
      syncInputValues(isCustomDomain);
      updateContinueButton();

      if (isCustomDomain && $customDomainInput.val().trim()) {
        verifyDomain($customDomainInput.val().trim());
      }
    }

    function handleFormSubmit() {
      const slugInput = state.isSubdomainMode ?
        $subdomainSection.find('input[name="form_community[slug]"]') :
        $customDomainSection.find('input[name="form_community[slug]"]');

      $subdomainSection.find('input').prop('disabled', !state.isSubdomainMode);
      $customDomainSection.find('input').prop('disabled', state.isSubdomainMode);
    }

    function handleDomainRefresh() {
      if (state.currentDomain) {
        verifyDomain(state.currentDomain);
      }
    }

    function handleAddDomain() {
      const domain = $customDomainInput.val().trim();
      if (!domain) return showStatus('Please enter a domain', false, elements.addDomainStatus);

      state.currentDomain = domain;
      $('#domain_text').text(domain);
      toggleDomainUI(true);
      verifyDomain(domain);
    }

    function handleEditDomain() {
      toggleDomainUI(false);
      $customDomainSection.show();
      $customDomainInput.val(state.currentDomain).trigger('focus');
    }

    async function verifyDomain(domain) {
      try {
        setLoadingState(true);
        const response = await $.ajax({
          url: '/domain/verify',
          data: { domain }
        });

        state.domainVerified = response.verified;
        showStatus(response.message, response.verified, elements.domainStatus);
      } catch (error) {
        state.domainVerified = false;
        showStatus('Verification failed. Please try again.', false, elements.domainStatus);
      } finally {
        setLoadingState(false);
        updateContinueButton();
      }
    }

    function toggleSections(isCustomDomain) {
      $subdomainSection.toggle(!isCustomDomain);
      $customDomainSection.toggle(isCustomDomain);
      elements.dnsTable.hide();
    }

    function toggleDomainUI(showDnsTable) {
      $('#custom_domain_group').toggle(!showDnsTable);
      elements.dnsTable.toggle(showDnsTable);
      elements.domainStatus.empty();
    }

    function setLoadingState(isLoading) {
      elements.refreshBtn.prop('disabled', isLoading)
        .html(isLoading ? '<i class="fas fa-spinner fa-spin"></i>' : '<i class="fas fa-sync-alt"></i>');
    }

    function showStatus(message, isSuccess, container) {
      const statusClass = isSuccess ? 'text-success' : 'text-danger';
      const icon = isSuccess ? 'fa-check-circle' : 'fa-times-circle';

      container.html(`
        <div class="d-flex align-items-center ${statusClass}">
          <i class="fas ${icon} me-2"></i>
          <span class="small ml-2">${message}</span>
        </div>
      `);
    }

    function updateContinueButton() {
      if (state.isChannelFeed) {
        $continueButton.prop('disabled', false);
        return;
      }

      const isDisabled = state.isSubdomainMode ?
        $subdomainSection.find('input').val().trim() === '' :
        !(state.domainVerified && $customDomainInput.val().trim());

      $continueButton.prop('disabled', isDisabled);
    }

    function syncInputValues(isCustomDomain) {
      const subdomainVal = $subdomainSection.find('input').val().trim();
      const customVal = $customDomainInput.val().trim();

      if (isCustomDomain && !customVal && subdomainVal) {
        $customDomainInput.val(subdomainVal);
      } else if (!isCustomDomain && !subdomainVal && customVal) {
        $subdomainSection.find('input').val(customVal);
      }
    }

    function handleInitialState() {
      if ($domainSwitch.length && $domainSwitch.is(':checked')) {
        const domain = $customDomainInput.val().trim();
        if (domain !== "") {
          state.currentDomain = domain;
          // Set the initial domain text (user sees the chosen domain)
          $('#domain_text').text(domain);
          // Hide the custom domain input group and show the DNS records table immediately
          toggleDomainUI(true);
          // Also hide the subdomain section for clarity
          $subdomainSection.hide();
          // Perform domain verification
          verifyDomain(domain);
          return; // Exit early; no need to trigger change event.
        }
      }
      // Otherwise, trigger change so that sections update normally
      $domainSwitch.trigger('change');
    }

    return { init };
  })();

  CommunitySetup.init();
});
