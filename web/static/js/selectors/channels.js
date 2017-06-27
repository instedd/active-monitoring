export const getById = (state, id) => state && state.channels.items && state.channels.items.find((c) => c.id == id)
