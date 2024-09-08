class Ticket::PerformChanges::Action::TicketDistribuctor < Ticket::PerformChanges::Action
  def execute(...)
    agents_with_tickets = User.agents.map do |agent|
      oldest_ticket = Ticket.where(owner_id: agent.id).order(created_at: :asc).first
      { agent: agent, oldest_ticket: oldest_ticket } if oldest_ticket
    end
    agents_with_tickets.compact! # Remove entradas nulas

    # Verifica se há agentes com tickets
    if agents_with_tickets.any?
      agent_with_oldest_ticket = agents_with_tickets.min_by { |entry| entry[:oldest_ticket].created_at }
      ticket.update(owner_id: agent_with_oldest_ticket[:agent].id) if agent_with_oldest_ticket
    else
      # Log ou tratativa caso nenhum ticket seja encontrado
      Rails.logger.warn('Nenhum agente com tickets encontrados.')
    end
  rescue => e
    Rails.logger.error("Erro ao distribuir ticket: #{e.message}")
    raise
  end
end