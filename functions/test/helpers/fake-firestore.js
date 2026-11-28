function createFakeFirestore(initialDocuments = {}) {
  const documents = new Map(
    Object.entries(initialDocuments).map(([path, data]) => [
      path,
      structuredClone(data),
    ]),
  );
  let transactionQueue = Promise.resolve();
  let autoId = 0;

  const db = {
    collection(name) {
      return collectionReference(name);
    },
    async runTransaction(callback) {
      const previous = transactionQueue;
      let release;
      transactionQueue = new Promise((resolve) => {
        release = resolve;
      });
      await previous;

      const writes = [];
      const transaction = {
        async get(reference) {
          if (reference.type === 'query' || reference.type === 'collection') {
            const docs = [];
            for (const [path, data] of documents) {
              const prefix = `${reference.collectionName}/`;
              if (!path.startsWith(prefix) || path.slice(prefix.length).includes('/')) {
                continue;
              }
              if (reference.type === 'collection' ||
                  data[reference.field] === reference.value) {
                docs.push(snapshot(path, data));
              }
            }
            return {
              docs: reference.limitCount
                ? docs.slice(0, reference.limitCount)
                : docs,
            };
          }
          return snapshot(reference.path, documents.get(reference.path));
        },
        update(reference, data) {
          writes.push({ kind: 'update', path: reference.path, data });
        },
        create(reference, data) {
          writes.push({ kind: 'create', path: reference.path, data });
        },
      };

      try {
        const result = await callback(transaction);
        for (const write of writes) {
          if (write.kind === 'create' && documents.has(write.path)) {
            throw new Error('Document already exists.');
          }
        }
        for (const write of writes) {
          if (write.kind === 'update') {
            if (!documents.has(write.path)) {
              throw new Error('Document does not exist.');
            }
            documents.set(write.path, {
              ...documents.get(write.path),
              ...structuredClone(write.data),
            });
          } else {
            documents.set(write.path, structuredClone(write.data));
          }
        }
        return result;
      } finally {
        release();
      }
    },
    read(path) {
      const data = documents.get(path);
      return data === undefined ? undefined : structuredClone(data);
    },
    paths() {
      return [...documents.keys()];
    },
  };

  function collectionReference(name) {
    return {
      type: 'collection',
      collectionName: name,
      doc(id) {
        const documentId = id ?? `auto-${++autoId}`;
        return {
          type: 'document',
          id: documentId,
          path: `${name}/${documentId}`,
        };
      },
      where(field, operator, value) {
        if (operator !== '==') throw new Error('Unsupported fake query.');
        return {
          type: 'query',
          collectionName: name,
          field,
          value,
          limit(count) {
            return { ...this, limitCount: count };
          },
        };
      },
    };
  }

  return db;
}

function snapshot(path, data) {
  return {
    id: path.slice(path.lastIndexOf('/') + 1),
    exists: data !== undefined,
    data: () => (data === undefined ? undefined : structuredClone(data)),
  };
}

module.exports = { createFakeFirestore };
