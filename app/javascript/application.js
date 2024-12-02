import "bootstrap";
import "admin-lte";
import "@nathanvda/cocoon";

import "lib/datatable";
import "custom_js/api_util";
import "custom_js/modal_handler";
import "custom_js/keyword_groups";
import "custom_js/header";
import "custom_js/search_contributor";
import 'custom_js/search_mute_contributor';
import 'custom_js/post_hashtag';
import 'custom_js/community_preview';
import 'custom_js/content_type'
import 'custom_js/admin'

import { far } from "@fortawesome/free-regular-svg-icons";
import { fas } from "@fortawesome/free-solid-svg-icons";
import { fab } from "@fortawesome/free-brands-svg-icons";
import { library } from "@fortawesome/fontawesome-svg-core";
import "@fortawesome/fontawesome-free";
library.add(far, fas, fab);

import Rails from "@rails/ujs";
Rails.start();

localStorage.setItem("selected", null);
localStorage.setItem("unselected", null);

import ClassicEditor from "@ckeditor/ckeditor5-build-classic";

$(document).ready(function () {
  document.querySelectorAll(".ckeditor").forEach((element) => {
    ClassicEditor.create(element).catch((error) => {
      console.error(error);
    });
  });

  const element = document.getElementById("community_bio");
  if (element) {
    ClassicEditor.create(element, {
      toolbar: ["bold", "italic", "link"],
    }).catch((error) => {
      console.error(error);
    });
  }

  const admin_note = document.getElementById("master_admin_note");
  if (admin_note) {
    ClassicEditor.create(admin_note, {
      toolbar: ["bold", "italic", "link"],
    }).catch((error) => {
      console.error(error);
    });
  }

  $(".select2").select2({
    dropdownParent: $("#keyFilterModal"),
    tags: true,
    placeholder: "Select an option",
    allowClear: true,
    theme: "bootstrap",
  });

  const keywordFilterForm = document.querySelector("#keyFilterModal form");

  if (keywordFilterForm) {
    keywordFilterForm.addEventListener("submit", function (event) {
      event.preventDefault();
      const formData = new FormData(keywordFilterForm);
      const url = keywordFilterForm.action;
      const submitButton = document.querySelector(".submit-btn");

      clearPreviousErrors();

      if (!validateKeywords()) {
        displayErrorMessage("Keyword cannot be blank.");
        enableSubmitButton(submitButton);
        return;
      }

      fetch(url, {
        method: "POST",
        headers: {
          "X-CSRF-Token": document
            .querySelector('meta[name="csrf-token"]')
            .getAttribute("content"),
        },
        body: formData,
      })
        .then((response) => response.json())
        .then((data) => {
          if (data.success) {
            location.reload();
          } else {
            enableSubmitButton(submitButton);
            handleKeywordFilterGroupErrors(data.error);
          }
        })
        .catch((error) => {
          console.error("Error submitting form:", error);
          displayErrorMessage(
            "An unexpected error occurred. Please try again."
          );
          enableSubmitButton(submitButton);
        });
    });
  }

  function clearPreviousErrors() {
    document.querySelectorAll(".error-message").forEach((el) => el.remove());
    document
      .querySelectorAll(".form-control")
      .forEach((el) => el.classList.remove("is-invalid"));
  }

  function validateKeywords() {
    let isValid = true;
    document
      .querySelectorAll(
        'input[name^="keyword_filter_group[keyword_filters_attributes]"][name$="[keyword]"]'
      )
      .forEach((input) => {
        if (!input.value.trim()) {
          input.classList.add("is-invalid");
          isValid = false;
        }
      });
    return isValid;
  }

  function displayErrorMessage(message) {
    const errorMessage = document.createElement("small");
    errorMessage.className = "error-message text-danger";
    errorMessage.textContent = message;
    document
      .querySelectorAll(
        'input[name^="keyword_filter_group[keyword_filters_attributes]"][name$="[keyword]"]'
      )
      .forEach((input) => {
        if (input.classList.contains("is-invalid")) {
          input.after(errorMessage.cloneNode(true));
        }
      });
  }

  function enableSubmitButton(button) {
    if (button) {
      button.disabled = false;
      button.removeAttribute("data-disable-with");
    }
  }

  function handleKeywordFilterGroupErrors(errorMessage) {
    const errors = errorMessage.split(", ");
    errors.forEach((error) => {
      const errorElement = document.createElement("small");
      errorElement.className = "error-message text-danger";
      errorElement.textContent = error;

      if (error.includes("Name")) {
        const nameInput = document.querySelector(
          'input[name="keyword_filter_group[name]"]'
        );
        if (nameInput) {
          nameInput.classList.add("is-invalid");
          nameInput.after(errorElement);
        }
      } else if (error.includes("Keyword")) {
        document
          .querySelectorAll(
            'input[name^="keyword_filter_group[keyword_filters_attributes]"][name$="[keyword]"]'
          )
          .forEach((input) => {
            if (input) {
              input.classList.add("is-invalid");
              input.after(errorElement);
            }
          });
      }
    });
  }

  const nestedAttributeContainer = document.querySelector(".nested-fields");

  if (
    nestedAttributeContainer &&
    nestedAttributeContainer.children.length === 0
  ) {
    const addNewLink = nestedAttributeContainer.querySelector(".add_fields");
    if (addNewLink) {
      addNewLink.click();
    }
  }

  const collapseToggles = document.querySelectorAll(".collapse-toggle");

  collapseToggles.forEach(function (toggle) {
    toggle.addEventListener("click", function () {
      const arrowDown = toggle.querySelector(".icon-arrow-down");
      const arrowUp = toggle.querySelector(".icon-arrow-up");

      if (toggle.getAttribute("aria-expanded") === "true") {
        arrowDown.style.display = "inline-block";
        arrowUp.style.display = "none";
      } else {
        arrowDown.style.display = "none";
        arrowUp.style.display = "inline-block";
      }
    });
  });

  const saveChangeButtons = document.querySelectorAll('.save-change');

  saveChangeButtons.forEach(button => {
    button.addEventListener('click', () => {
      window.location.reload();
    });
  });

  const uploadInputs = document.querySelectorAll(".upload-input");

  if(uploadInputs){
    uploadInputs.forEach((input) => {
      const previewId = input.getAttribute("data-preview-id");
      const errorId = input.getAttribute("data-error-id");
      const maxSizeMB = input.getAttribute("data-max-size");
      const isBanner = input.id === "customFile";

      setupFileUpload(input.id, previewId, errorId, maxSizeMB, isBanner);
    })
  }

  function setupFileUpload(inputId, previewId, errorId, maxSizeMB, isBanner) {
    const input = document.getElementById(inputId);
    const preview = document.getElementById(previewId);
    const errorContainer = document.getElementById(errorId);

    input.addEventListener("change", function () {
      const file = this.files[0];
      errorContainer.textContent = "";

      if (file) {
        const allowedTypes = ["image/jpeg", "image/png", "image/svg+xml"];
        if (!allowedTypes.includes(file.type)) {
          errorContainer.textContent = "Only JPG, PNG, and SVG images are allowed.";
          this.value = "";
          return;
        }

        // Validate file size
        const maxSizeInBytes = maxSizeMB * 1024 * 1024;
        if (file.size > maxSizeInBytes) {
          errorContainer.textContent = `File size must be less than ${maxSizeMB} MB.`;
          this.value = "";
          return;
        }

        const reader = new FileReader();
        reader.onload = function (e) {
          preview.style.display = "block";
          preview.src = e.target.result;

          if (isBanner) {
            // preview.style.width = "100%";
            // preview.style.height = "100%";
            // preview.style.objectFit = "cover";
            // preview.style.position = "absolute";
            // preview.style.top = "0";
            // preview.style.left = "0";
            document.querySelector('.dropzone-placeholder').style.display = 'none';
          }
        };
        reader.readAsDataURL(file);
      }
    });

    if (isBanner) {
      const dropzone = document.getElementById("bannerDropzone");

      dropzone.addEventListener("dragover", function (e) {
        e.preventDefault();
        dropzone.style.backgroundColor = "#e9ecef";
      });

      dropzone.addEventListener("dragleave", function () {
        dropzone.style.backgroundColor = "#f8f9fa";
      });

      dropzone.addEventListener("drop", function (e) {
        e.preventDefault();
        dropzone.style.backgroundColor = "#f8f9fa";
        input.files = e.dataTransfer.files;
        input.dispatchEvent(new Event("change"));
      });
    }
  };
});

const togglePassword = (e) => {
  let input = e.closest('div').querySelector("input[type='password'], input[type='text']");
  if (input) {
    if (input.type === "password") {
      e.setAttribute("class", "svg-inline--fa fa-eye red");
      input.type = "text";
    } else {
      e.setAttribute("class", "svg-inline--fa fa-eye-slash red");
      input.type = "password";
    }
  } else {
    console.error("No input element found!");
  }
};

window.togglePassword = togglePassword;
