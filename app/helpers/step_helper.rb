module StepHelper
  def render_step(step_number, display_number, title, description)
    content_tag :div, class: step_class(step_number), data: { step: step_number } do
      concat(content_tag(:div, content_tag(:span, display_number, class: "small #{'step-no' if @current_step > step_number}"), class: 'circle'))
      concat(content_tag(:div, content_tag(:strong, title) + content_tag(:p, description, class: 'desc small'), class: 'label'))
    end
  end

  def step_class(step_number)
    if @current_step == step_number
      'step active'
    elsif @current_step > step_number
      'step done'
    else
      'step'
    end
  end
end
